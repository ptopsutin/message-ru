#!/bin/bash

set -e

FILENAME="./files/ips-80.txt"
TMP_FILE=$FILENAME".tmp"

rm -f $TMP_FILE
touch $TMP_FILE


# Load user agents
source ./http/user-agent.sh

TOR_PROXY=""
CONNECTION_TIMEOUT="--connect-timeout 0.5 --max-time 1"
SILENT_OUTPUT="--silent --output /dev/null"

# Command line params
for i in "$@"; do
  case $i in
    -t=*|--tor=*)
      TOR_PROXY="--socks5-hostname ${i#*=}"
      # TOR connections will be slower
      CONNECTION_TIMEOUT="--connect-timeout 1 --max-time 2"
      echo "Using TOR: ${i#*=}"
      echo " -> testing connection to Tor..."
      set +e
      LANG=en_US curl $TOR_PROXY $SILENT_OUTPUT $CONNECTION_TIMEOUT www.google.com
      RES=$?
      set -e
      if [[ $RES -ne 0 ]]; then
      	echo " x> connection failed... make sure Tor service is running"
      	exit 1;
      fi
      shift # past argument=value
      ;;

    -*|--*)
      echo "http-msg.sh: Unknown option $i"
      exit 1
      ;;
    
    *)
      ;;
  esac
done


if [[ -p /dev/stdin ]]; then
	echo "Starting..."
	COUNTER=0
	while read line; do
		ADDRESS=http://$line/github.com/vshymanskyy/StandWithUkraine/blob/main/docs/ToRussianPeople.md
		set +e
		LANG=en_US curl $TOR_PROXY $SILENT_OUTPUT $CONNECTION_TIMEOUT -H "Host:stop.the.war" --user-agent "$(randomuseragent)" --head $ADDRESS
		RES=$?
		set -e
		if [[ $RES -eq 0 || $RES -eq 52 || $RES -eq 56 ]]; then
			echo $line >> $TMP_FILE
		elif [[ $RES -ne 7 && $RES -ne 28 ]]; then
			echo $line >> $TMP_FILE
			echo "WARN: Got curl code "$RES" for "$ADDRESS
		fi

		COUNTER=$((COUNTER+1))
		if [[ $(($COUNTER % 100)) -eq 0 ]]; then
			echo "Reached "$(cat $TMP_FILE | wc -l)" hosts so far (from "$COUNTER" requests)"
		fi
	done < /dev/stdin
	mv -f $TMP_FILE $FILENAME
	NUM_IPS=$(wc -l $FILENAME)
	echo "Done: list of IPs with successful connection at "$FILENAME" ("$NUM_IPS" IPs)"
else
	echo "Error: no pipe input"
	exit 1
fi
