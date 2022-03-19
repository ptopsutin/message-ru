#!/bin/bash

UA_FILE="./files/user-agents.txt"

# 1. Download list of user agents
if [[ $FORCE -eq 1 || ! -f $UA_FILE ]]; then
	echo "Downloading user agents list"
	curl https://gist.githubusercontent.com/pzb/b4b6f57144aea7827ae4/raw/cf847b76a142955b1410c8bcef3aabe221a63db1/user-agents.txt > $UA_FILE.tmp
	mv -f $UA_FILE.tmp $UA_FILE
else
	echo "File "$UA_FILE" already exists - skipping download."
fi


function randomuseragent {
	shuf -n 1 $UA_FILE
}