#  Copyright 2025 Paul Schulze, All rights reserved.

import argparse
import os
import sys
import time

def wait_for_device(device: str) -> None:
    """Wait for a device to be connected and ready"""
    print(f"Waiting for device {device} to be connected...")
    if sys.platform == "win32":
        # On Windows, we need to wait for COM* ports to be available
        import serial.tools.list_ports
        while True:
            available_ports = [port.device for port in serial.tools.list_ports.comports()]
            if device in available_ports:
                break
            time.sleep(1)
    else:
        # Any unix should be able to wait for devices in /dev
        while not os.path.exists(device):
            time.sleep(1)
    print(f"Device {device} is now connected.")

def main() -> None:
    parser = argparse.ArgumentParser(description="Wait for a device to be connected.")
    parser.add_argument("device", help="Path to the device file (e.g., /dev/ttyUSB0)")
    args = parser.parse_args()
    wait_for_device(args.device)

if __name__ == "__main__":
    main()