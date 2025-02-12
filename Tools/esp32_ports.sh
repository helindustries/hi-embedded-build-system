#!/bin/bash

ESPTOOL=$1
shift 1
export LANG=C
export LC_ALL=C

for port in "$@"
do
    if "$ESPTOOL" --port "$port" --baud 115200 --connect-attempts 2 chip_id | grep "Connecting\." >/dev/null 2>&1
    then
        echo "$port";
    fi
done
