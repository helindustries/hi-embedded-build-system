#!/usr/bin/env python3
import serial

def teensy_reset(port):
    with serial.Serial(port, 9600) as s:
        s.timeout = .1
        print(s.readline().strip())
        s.write('r')
        print(s.readline().strip())

if __name__ == '__main__':
    import sys
    import time
    if len(sys.argv) < 2:
        print("Usage: %s <port>")
        sys.exit(1)
    time.sleep(0.5)
    teensy_reset(sys.argv[1])
