#  Copyright 2025 Paul Schulze, All rights reserved.
import os
import subprocess
import sys
from typing import List

def ghdl_analyze(ghdl: str, ghdl_build_dir: str, ghdl_args: List[str], work: str, target: str) -> None:
    print(f"Analyzing {target} ({work})")
    work_dir = os.path.join(ghdl_build_dir, work)
    os.makedirs(work_dir, exist_ok=True)
    ghdl_args.append("--workdir=" + work_dir)
    ghdl_args.append("--work=" + work)
    ghdl_args.append(target)
    ghdl_args.insert("-a")
    ghdl_args.insert(0, ghdl)
    result = subprocess.run(ghdl_args, stdout=sys.stdout, stderr=sys.stderr, text=True)
    sys.exit(result.returncode)

def main() -> None:
    if len(sys.argv) < 5:
        print("Usage: ghdl_analyze.py <ghdl> <ghdl_build_dir> [ghdl_args...] <target> <work>")
        sys.exit(1)
    argv = list(sys.argv[1:])
    ghdl = argv.pop(0)
    ghdl_build_dir = argv.pop(0)
    target = argv.pop()
    work = argv.pop()
    ghdl_args = argv
    ghdl_analyze(ghdl, ghdl_build_dir, ghdl_args, work, target)

if __name__ == "__main__":
    main()