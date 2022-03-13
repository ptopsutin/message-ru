# Want to send a message to Russia?

Here is a list of commands that you can run (on Linux) to collect, generate and verify IPs that belong to russian hosts.

To those IPs you can then send an HTTP request with the following link in the path: github.com/vshymanskyy/StandWithUkraine/blob/main/docs/ToRussianPeople.md

## Dependencies

To install dependencies (assuming you are using Ubuntu):

```

```

## Method 1 - automated (local run)

This method differs a bit from the manual procedure: it just connects to the hosts without using nmap to verify open ports.

First, you need to make sure you have all you need:

```
RUN apt-get update && \
	apt-get install -y git curl csvkit geoip-bin
```

After you clone this repo, run:

```
./start.sh --mode=http
```

That's it - let it run.

You can stop it at any time. The stages are implemented in a way that it prepares the list of IPs once and use then existing data
on the follwing runs. If you stop at a stage, the next time you run it will skip the previous stages.

## Method 2 - use Docker

```
docker build -t stop-putin .
docker run -d --name stop-putin -u 1001 --rm -v $(pwd)/docker-files:/home/stop-putin/files stop-putin
```

## Method 3 - manual

### 1. Download list of russian IP addresses (may be outdated, but a good start)

```
curl 'https://www.nirsoft.net/countryip/ru.csv' > ./files/ru.csv
```

### 2. Generate IP prefix files based on the downloaded csv

```
csvcut -c 2 ./files/ru.csv | sed 's/\.255/\./' | grep --color=never '\.$' | sort | uniq > ./files/ip-prefixes.txt
```

### 3. Generate all possible IPs based on the prefixes

```
cat ./files/ip-prefixes.txt | ./ips/generate-ips.sh > ./files/generated-ips.txt
```

### 4. Filter by updated geographical position

```
cat ./files/generated-ips.txt | ./ips/only-ru.sh > ./files/russian-ips.txt
```

### 5. Port scan

```
nmap -Pn -n -p 21,22,80,110,143,631 -iL ./files/russian-ips.txt -oG ./files/port-scan.txt
```

Explanation:
* `-Pn` - no ping
* `-n` - no reverse lookup (domain lookup)
* `-iL` - input list file
* `-oG` - output

### 6. Extract IPs with open port

Extract IPs with port 80 open:

```
cat ./files/port-scan.txt | grep -i '80\/\(filtered\|open\)' | cut -d' ' -f2 > ./files/ips-80-nmap.txt
```

### 7. Execute curl

```
cat ./files/ips-80-nmap.txt | ./http/http-msg.sh
```
