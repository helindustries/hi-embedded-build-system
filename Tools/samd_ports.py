#  Copyright 2025 Paul Schulze, All rights reserved.
#CPU_DEVICE_PORT ?= $(strip $(shell for port in $(call print,"$(BUILD_DIR)/.last_samd_port") "/dev/cu.usb"*; do if $(BOSSAC) --port="$port" -i > /dev/null 2>&1; then echo "$port"; break; fi; done))
import subprocess
import sys
from typing import List

def find_samd_ports(bossac: str, ports: List[str]) -> None:
    for port in ports:
        try:
            cmd = [bossac, "--port", port, "-i"]
            result = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, text=True)
            if result.returncode == 0:
                print(port)
                # XXX: Exit with the first successful port for now, later we want to perform
                #      all actions on all available ports for more pipeline automation
                break
        except subprocess.SubprocessError:
            pass

def main():
    bossac = sys.argv[1]
    ports = sys.argv[2:]
    find_samd_ports(bossac, ports)

if __name__ == "__main__":
    main()