#!/bin/bash

DIR="$(dirname "$0")"
DIR=${DIR:-"."}

#ps -A | grep run_logic.sh | grep -v grep | sed -E 's%([0-9]+).*%\1%' | xargs -I {} kill {}
sleep 3
/usr/bin/env python3 "$DIR/run_logic.py" "$@"
sleep 2
