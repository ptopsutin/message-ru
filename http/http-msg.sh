#!/bin/bash

set -e

FILENAME="./files/ips-80.txt"
TMP_FILE=$FILENAME".tmp"

rm -f $TMP_FILE
touch $TMP_FILE

if [[ -p /dev/stdin ]]; then
	echo "Starting..."
	COUNTER=0
	while read line; do
		ADDRESS=http://$line/github.com/vshymanskyy/StandWithUkraine/blob/main/docs/ToRussianPeople.md
		set +e
		LANG=en_US curl --silent --output /dev/null --connect-timeout 0.1 --max-time 1 -H "Host:stop.the.war" --user-agent "Mozilla/5.0 (X11; Linux x86_64; rv:98.0) Gecko/20100101 Firefox/98.0" --head $ADDRESS
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
			echo "Reached "$(cat $TMP_FILE | wc -l)" hosts so far"
		fi
	done < /dev/stdin
	mv -f $TMP_FILE $FILENAME
	NUM_IPS=$(wc -l $FILENAME)
	echo "Done: list of IPs with successful connection at "$FILENAME" ("$NUM_IPS" IPs)"
else
	echo "Error: no pipe input"
	exit 1
fi
