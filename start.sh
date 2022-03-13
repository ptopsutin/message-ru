#!/bin/bash

set -euo pipefail

FORCE=0
MODE=""

function modes {
	echo "Usage:"
	echo '	./start --mode=<value>'
	echo "Modes: http, ftp"
}

for i in "$@"; do
  case $i in

    -m=*|--mode=*)
      MODE="${i#*=}"
      shift # past argument=value
      ;;
    
    --force)
      FORCE=1
      shift # past argument with no value
      ;;
    
    -*|--*)
      echo "Unknown option $i"
      modes
      exit 1
      ;;
    
    *)
      ;;
  esac
done

mkdir -p ./files
rm -f ./files/*.tmp

# 1. Download list of russian IP addresses (may be outdated, but a good start)
if [[ $FORCE -eq 1 || ! -f "./files/ru.csv" ]]; then
	echo "Downloading ru.csv..."
	curl 'https://www.nirsoft.net/countryip/ru.csv' > ./files/ru.csv.tmp
	mv -f ./files/ru.csv.tmp ./files/ru.csv
else
	echo "File ru.csv already exists - skipping download."
fi


# 2. Generate IP prefix files based on the downloaded csv
if [[ $FORCE -eq 1 || ! -f "./files/ip-prefixes.txt" ]]; then
	echo "Collect IP prefixes"
	csvcut -c 2 ./files/ru.csv | sed 's/\.255/\./' | grep --color=never '\.$' | sort | uniq > ./files/ip-prefixes.txt.tmp
	mv -f ./files/ip-prefixes.txt.tmp ./files/ip-prefixes.txt
else
	echo "File ip-prefixes.txt already exists - skipping IP prefix collection."
fi

# 3. Generate all possible IPs based on the prefixes
if [[ $FORCE -eq 1 || ! -f "./files/generated-ips.txt" ]]; then
	echo "Generate IP combinations"
	cat ./files/ip-prefixes.txt | ./ips/generate-ips.sh > ./files/generated-ips.txt.tmp
	mv -f ./files/generated-ips.txt.tmp ./files/generated-ips.txt
else
	echo "File generated-ips.txt already exists - skipping IP combination generation."
fi

# 4. Filter by updated geographical position
if [[ $FORCE -eq 1 || ! -f "./files/russian-ips.txt" ]]; then
	echo "Filter by location (Russia only)"
	cat ./files/generated-ips.txt | ./ips/only-ru.sh > ./files/russian-ips.txt.tmp
	mv -f ./files/russian-ips.txt.tmp ./files/russian-ips.txt
else
	echo "File russian-ips.txt already exists - skipping IP filtering by geolocation."
fi

if [[ -z $MODE ]]; then
	echo "No mode selected."
	modes
	exit 0;
fi

##
# HTTP
##

if [[ $MODE == "http" ]]; then

	if [[ $FORCE -eq 1 && -f "./files/ips-80.txt" ]]; then
		rm -f ./files/ips-80.txt
		echo "Removing cached list of IPs with port 80 open: ./files/ips-80.txt"
	fi

	if [[ ! -f "./files/ips-80.txt" ]]; then
		# For the first run, use all IPs (it will create a cached list of IPs that connected successfully)
		echo "This is the first run - it will be slow, so bear with me"
		cat ./files/russian-ips.txt | ./http/http-msg.sh
		echo "From here on, only the successfully reached IPs will be used - will be much faster!"
	fi

	while [ true ]
	do
		# Use and update optimized list
		cat ./files/ips-80.txt | ./http/http-msg.sh
	done
	exit 0;
fi

echo "Invalid mode: "$MODE
modes
exit 1;