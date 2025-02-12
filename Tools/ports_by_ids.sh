#!/bin/bash

LOWER_PID=$(echo "$2" | tr '[:upper:]' '[:lower:]')
LOWER_VID=$(echo "$3" | tr '[:upper:]' '[:lower:]')
ls --color=never /dev/cu.usb* | sed -E 's&/dev/cu\.usb[a-z]+([0-9]+)[0-9]$&\1&' | grep -v "/dev/cu.usb" | xargs -I {} bash -c 'system_profiler SPUSBDataType | grep -B 6 "$1" | grep -A 1 "Product ID: $LOWER_PID" | grep "Vendor ID: $LOWER_VID" > /dev/null && ls --color=never /dev/cu.usb*$1* | head -n 1' _ {} $1 $2
