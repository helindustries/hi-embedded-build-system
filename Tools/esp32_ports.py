#!/usr/bin/env python3

import os
import sys
import subprocess
import locale
from ports_by_ids import get_ports_by_ids

def main():
    if len(sys.argv) < 4:
        print("Usage: esp32_ports.py ESPTOOL PID VID [ports...]")
        sys.exit(1)

    # Set locale to C for consistent output
    locale.setlocale(locale.LC_ALL, 'C')

    esptool = sys.argv[1]
    pid = sys.argv[2]
    vid = sys.argv[3]
    ports = sys.argv[4:]

    # Get matching ports from ports_by_ids module
    matching_ports = get_ports_by_ids(pid, vid, ports)

    for port in matching_ports:
        try:
            # Try to connect to the ESP32 device
            cmd = [esptool, "--port", port, "--baud", "115200", "--connect-attempts", "2", "chip_id"]
            result = subprocess.run(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True
            )

            # Check if connection was successful
            if "Connecting." in result.stdout:
                print(port)
                # XXX: Exit with the first successful port for now, later we want to perform
                #      all actions on all available ports for more pipeline automation
                break
        except subprocess.SubprocessError:
            # Ignore connection failures
            pass

if __name__ == "__main__":
    main()
