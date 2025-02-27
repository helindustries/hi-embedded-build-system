#!/bin/bash

LOWER_PID=$(echo "$1" | tr '[:upper:]' '[:lower:]')
LOWER_VID=$(echo "$2" | tr '[:upper:]' '[:lower:]')
shift 2
for port in "$@"
do
    port_base="$(echo "$port" | sed -E 's&/dev/cu\.usb[a-z]+([0-9]+)[0-9]$&\1&')"
    if system_profiler SPUSBDataType 2>/dev/null | egrep -B 6 "Location ID:.*$port_base" | grep -A 1 "Product ID: $LOWER_PID" | grep "Vendor ID: $LOWER_VID" > /dev/null
    then
        echo "$port"
        continue
    fi

    port_serial="$(echo "$port" | sed -E 's&/dev/cu\.usb[a-z]+-([0-9A-F]+)$&\1&')"
    if system_profiler SPUSBDataType 2>/dev/null | grep -B 3 "Serial Number: $port_serial" | grep -A 1 "Product ID: $LOWER_PID" | grep "Vendor ID: $LOWER_VID" > /dev/null
    then
        echo "$port"
    fi
done
