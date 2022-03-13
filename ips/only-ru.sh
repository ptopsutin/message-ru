#!/bin/bash

set -euo pipefail

if [[ -p /dev/stdin ]]; then
	while read line; do
		VALUE=$(geoiplookup $line)
		if grep -q "Russian" <<< "$VALUE"; then
			echo $line
		fi;
	done < /dev/stdin
else
	exit 1;
fi
