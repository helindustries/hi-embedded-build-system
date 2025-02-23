#!/bin/bash

DIR="$(dirname "$0")"
ESPTOOL=$1
PID=$2
VID=$3
shift 3
export LANG=C
export LC_ALL=C

for port in $(bash $DIR/ports_by_ids.sh $PID $VID "$@")
do
    if "$ESPTOOL" --port "$port" --baud 115200 --connect-attempts 2 chip_id | grep "Connecting\." >/dev/null 2>&1
    then
        echo "$port";
    fi
done
