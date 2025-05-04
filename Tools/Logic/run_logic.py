#!/usr/bin/env python3
from typing import List
import saleae
import time
import os
import sys
import multiprocessing

def start_capture() -> None:
    print("Connecting to Logic")
    try:
        s: saleae.Saleae = saleae.Saleae()
    except:
        print("Failed to connect, logic may not be running!")
        return

    print("Starting capture")
    try:
        s.capture_start()
    except:
        print("Failed to start capture")
        return

    finished: bool = False
    wait_for: int = 120
    while not finished:
        wait_for -= 1
        if wait_for < 0:
            print("Capture timed out")
            return

        time.sleep(1)
        try:
            finished = s.is_processing_complete()
        except:
            pass

    print("Capture finished")

def main(args: list[str]) -> None:
    time.sleep(3)
    start_capture()
    if len(args) > 1 and args[1] == "--focus":
        print("Focusing Logic")
        focus_if_running: str = os.path.join(os.path.dirname(sys.argv[0]), "focus_if_running.scpt")
        os.system("osascript %s Logic" % focus_if_running)
        time.sleep(10)
    time.sleep(2)

if __name__ == "__main__":
    main(sys.argv)
