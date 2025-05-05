#  Copyright 2025 Paul Schulze, All rights reserved.
import os
import shutil
import sys

def clean_fpga_reports(reports, mrs, temps):
    if reports:
        os.makedirs("reports", exist_ok=True)
        for report in reports:
            if os.path.exists(report):
                shutil.copy(report, "reports")
    if mrs:
        os.makedirs("reports/mr", exist_ok=True)
        for report in mrs:
            if os.path.exists(report):
                shutil.copy(report, "reports/mr")

    files = reports
    files.extend(mrs)
    files.extend(temps)
    for path in files:
        try:
            os.remove(path)
        except:
            pass

def index_of(args, arg):
    """Find the index of an argument in a list of arguments."""
    try:
        return args.index(arg)
    except ValueError:
        return -1

def main():
    argv = sys.argv[1:]
    reports_index = index_of(argv, "--reports")
    mrs_index = index_of(argv, "--mrs")
    temps_index = index_of(argv, "--temps")

    if reports_index > 0 and mrs_index > 0 and reports_index > mrs_index:
        print("Error: --reports must come before --mrs", file=sys.stderr)
        sys.exit(1)
    if reports_index > 0 and temps_index > 0 and reports_index > temps_index:
        print("Error: --reports must come before --temps", file=sys.stderr)
        sys.exit(1)
    if mrs_index > 0 and temps_index > 0 and  mrs_index > temps_index:
        print("Error: --mr must come before --temps", file=sys.stderr)
        sys.exit(1)

    if reports_index == -1:
        reports = []
    else:
        if mrs_index != -1:
            reports_end = mrs_index
        elif temps_index != -1:
            reports_end = temps_index
        else:
            reports_end = len(argv)
        reports = argv[reports_index + 1:reports_end]

    if mrs_index == -1:
        mrs = []
    else:
        if temps_index != -1:
            mrs_end = temps_index
        else:
            mrs_end = len(argv)
        mrs = argv[mrs_index + 1:mrs_end]

    if temps_index == -1:
        temps = []
    else:
        temps = argv[temps_index + 1:]

    clean_fpga_reports(reports, mrs, temps)

if __name__ == "__main__":
    main()