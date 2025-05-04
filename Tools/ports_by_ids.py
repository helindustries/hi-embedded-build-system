#!/usr/bin/env python3

import re
import subprocess
import os
import sys

def get_ports_by_ids_macos(pid, vid, ports):
    """Find ports that match the given product ID and vendor ID on macOS."""
    lower_pid = pid.lower()
    lower_vid = vid.lower()
    matching_ports = []

    # Get USB device information
    try:
        system_profiler_output = subprocess.check_output(
            ["system_profiler", "SPUSBDataType"],
            stderr=subprocess.DEVNULL
        ).decode('utf-8')
    except subprocess.SubprocessError:
        return matching_ports

    for port in ports:
        # Handle the location ID pattern
        port_base_match = re.search(r'/dev/cu\.usb[a-z]+([0-9]+)[0-9]$', port)
        if port_base_match:
            port_base = port_base_match.group(1)
            location_pattern = f"Location ID:.*{port_base}"

            # Find block of text around the location ID
            location_blocks = re.split(r'\n\s*\n', system_profiler_output)
            for block in location_blocks:
                if re.search(location_pattern, block, re.IGNORECASE):
                    if (f"Product ID: {lower_pid}" in block.lower() and
                        f"Vendor ID: {lower_vid}" in block.lower()):
                        matching_ports.append(port)
                        break

        # Handle the serial number pattern
        if port not in matching_ports:  # Only check if not already matched
            port_serial_match = re.search(r'/dev/cu\.usb[a-z]+-([0-9A-F]+)$', port)
            if port_serial_match:
                port_serial = port_serial_match.group(1)
                serial_pattern = f"Serial Number: {port_serial}"

                # Find block of text around the serial number
                serial_blocks = re.split(r'\n\s*\n', system_profiler_output)
                for block in serial_blocks:
                    if serial_pattern in block:
                        if (f"Product ID: {lower_pid}" in block.lower() and
                            f"Vendor ID: {lower_vid}" in block.lower()):
                            matching_ports.append(port)
                            break

    return matching_ports

def get_ports_by_ids_linux(pid, vid, ports):
    """Find ports that match the given product ID and vendor ID on Linux."""
    matching_ports = []

    # On Linux, USB device info can be found in /sys/bus/usb/devices/
    try:
        usb_devices = os.listdir("/sys/bus/usb/devices/")
    except (FileNotFoundError, PermissionError):
        return matching_ports

    # Map between ttyUSB/ttyACM devices and their USB info
    device_map = {}

    # Loop through all USB devices
    for device in usb_devices:
        device_path = f"/sys/bus/usb/devices/{device}"

        # Check if this is a USB device with VID and PID
        try:
            with open(f"{device_path}/idVendor", "r") as f:
                vendor = f.read().strip()
            with open(f"{device_path}/idProduct", "r") as f:
                product = f.read().strip()

            # Check if VID and PID match
            if vendor.lower() == vid.lower() and product.lower() == pid.lower():
                # Find all serial ports created by this device
                for subdir, _, _ in os.walk(device_path):
                    tty_dir = os.path.join(subdir, "tty")
                    if os.path.exists(tty_dir):
                        for tty_name in os.listdir(tty_dir):
                            device_map[f"/dev/{tty_name}"] = (vendor, product)
        except (FileNotFoundError, PermissionError):
            continue

    # Check if any of the provided ports match our device_map
    for port in ports:
        # For Linux, port might be a symlink - resolve it
        try:
            real_port = os.path.realpath(port)
            port_base = os.path.basename(real_port)

            # Check if this port is in our device map
            if port in device_map or f"/dev/{port_base}" in device_map:
                matching_ports.append(port)
                continue

            # For ACM and USB devices, check if they match by pattern
            if "ttyACM" in port or "ttyUSB" in port:
                for dev_port, (dev_vid, dev_pid) in device_map.items():
                    if port_base in dev_port and dev_vid.lower() == vid.lower() and dev_pid.lower() == pid.lower():
                        matching_ports.append(port)
                        break
        except (FileNotFoundError, PermissionError):
            continue

    return matching_ports

def get_ports_by_ids_windows(pid, vid, ports):
    """Find ports that match the given product ID and vendor ID on Windows."""
    matching_ports = []

    # On Windows, we'll use wmic to get device information
    try:
        # Get a list of all serial ports with their PnP Device ID
        wmic_output = subprocess.check_output(
            ["wmic", "path", "Win32_PnPEntity", "where",
             "ClassGuid='{4d36e978-e325-11ce-bfc1-08002be10318}'",
             "get", "Caption,DeviceID", "/format:csv"],
            stderr=subprocess.DEVNULL
        ).decode('utf-8', errors='ignore')
    except (subprocess.SubprocessError, FileNotFoundError):
        return matching_ports

    # Process the CSV output
    lines = wmic_output.strip().split('\n')
    if len(lines) < 2:  # Header only or nothing
        return matching_ports

    # Map COM ports to their device IDs
    port_to_device = {}

    for line in lines[1:]:  # Skip header
        if not line.strip():
            continue

        parts = line.strip().split(',')
        if len(parts) < 3:
            continue

        _, caption, device_id = parts

        # Extract COM port number from caption
        com_match = re.search(r'(COM\d+)', caption)
        if not com_match:
            continue

        com_port = com_match.group(1)

        # Check if the device ID contains the VID and PID
        vid_pattern = f"VID_{vid}"
        pid_pattern = f"PID_{pid}"

        if vid_pattern.lower() in device_id.lower() and pid_pattern.lower() in device_id.lower():
            port_to_device[com_port] = device_id

    # Check if any of our ports match
    for port in ports:
        # Extract COM port name for comparison
        port_match = re.search(r'(COM\d+)', port, re.IGNORECASE)
        if port_match:
            com_port = port_match.group(1)
            if com_port in port_to_device:
                matching_ports.append(port)

    return matching_ports

def get_ports_by_ids(pid, vid, ports):
    """Find ports that match the given product ID and vendor ID across platforms."""
    # Detect platform
    platform = sys.platform

    # Call the appropriate platform-specific function
    if platform.startswith('darwin'):
        return get_ports_by_ids_macos(pid, vid, ports)
    elif platform.startswith('linux'):
        return get_ports_by_ids_linux(pid, vid, ports)
    elif platform.startswith('win'):
        return get_ports_by_ids_windows(pid, vid, ports)
    else:
        # Unsupported platform
        return []

if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(1)

    pid = sys.argv[1]
    vid = sys.argv[2]
    ports = sys.argv[3:]

    for port in get_ports_by_ids(pid, vid, ports):
        print(port)
