#  Copyright 2025 Paul Schulze, All rights reserved.
#
# Create a new static library from a list of object files and static libraries.
# This script is required, because ar does not support nested archives on some platforms and
# dealing with unpacking and repacking is not possible in a portable way for all platforms.

import glob
import os
import subprocess
import sys
from typing import List

def make_static_library(ar_with_flags_and_target: List[str], source_files: List[str]) -> None:
    obj_files = [obj for obj in source_files if not obj.endswith(".a")]
    if obj_files:
        # Create the static library with the provided objects
        cmd = ar_with_flags_and_target
        cmd.extend(obj_files)
        result = subprocess.run(cmd, stdout=sys.stdout, stderr=sys.stderr, text=True)
        if result.returncode != 0:
            sys.exit(result.returncode)

    lib_files = [lib for lib in source_files if lib.endswith(".a")]
    if lib_files:
        target = ar_with_flags_and_target[-1]
        temp_dir = os.path.join(os.path.dirname(target), ".temp")
        os.makedirs(temp_dir)
        current_dir = os.getcwd()
        os.chdir(temp_dir)
        for lib in lib_files:
            cmd = [ar_with_flags_and_target[0], "-x", lib]
            result = subprocess.run(cmd, stdout=sys.stdout, stderr=sys.stderr, text=True)
            if result.returncode != 0:
                sys.exit(result.returncode)

            cmd = list(ar_with_flags_and_target)
            cmd.extend(glob.glob("*.o"))
            result = subprocess.run(cmd, stdout=sys.stdout, stderr=sys.stderr, text=True)
            if result.returncode != 0:
                sys.exit(result.returncode)

            for obj in glob.glob("*"):
                os.remove(obj)
        os.chdir(current_dir)
        os.rmdir(temp_dir)

def main():
    if len(sys.argv) < 5:
        print("Usage: make_static_library.py <ar> [arflags] <target> -- <objects>")
        sys.exit(1)
    argv = sys.argv[1:]
    try:
        arflags_end = argv.index("--")
    except ValueError:
        print("Error: -- not found in arguments, no objects specified")
        sys.exit(1)
    ar_with_flags_and_target = argv[:arflags_end]
    source_files = argv[arflags_end + 1:]

    make_static_library(ar_with_flags_and_target, source_files)

if __name__ == "__main__":
    main()