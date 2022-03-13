#!/bin/bash

set -euo pipefail

if [[ -p /dev/stdin ]]; then
	while read line; do
		for d in $(seq 1 254); do
			IP=$line$d
			echo $IP
		done
	done < /dev/stdin
else
	exit 1;
fi
