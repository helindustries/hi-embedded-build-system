#!/usr/bin/env python3
import subprocess
from typing import Iterable, Tuple, Self, Match, Pattern, List, Optional
from dataclasses import dataclass
from enum import StrEnum
import re
import os

error_regex: list[str] = [
    "^ERROR:(.*?)\\s-\\s\"(\\.\\.\\/\\.\\.\\/)?(Z:)?(?P<file>.*?)\"\\s[Ll]ine\\s(?P<line>\\d+)[\\:\\.]\\s(?P<message>.*)",
    "^ERROR:(.*?)\\s-\\s(?P<message_pre>.*?)((\\$n\\$)|(\\s))\\[(Z:)?(?P<file>.*?)\\((?P<line>\\d+)\\)\\]((\\:\\s)|(.\\$n\\$))(?P<message>.*)",
    "^ERROR:(.*?)\\s-\\s(?P<message>.*?)((\\$n\\$)|(\\s))\\[(Z:)?(?P<file>.*?)\\((?P<line>\\d+)\\)\\]",
    "^ERROR:(.*?)\\s-\\s(?P<message>.*)",
    "^ERROR\\s-\\s(.*?)\\:\\s+(Z:)?(?P<file>.*)\\((?P<line>\\d+), (\\d+)\\)\\:\\s(?P<message>.*)",
    "^ERROR\\s-\\s(.*?)\\:\\s+(Z:)?(?P<file>.*)\\((?P<line>\\d+)\\)\\:\\s(?P<message>.*)",
    "^ERROR\\s-\\s(.*?)\\:\\s+(Z:)?(?P<file>.*)\\:\\s(?P<message>.*)",
    "^ERROR\\s-\\s(.*?)\\:\\s(?P<message>.*)",
    "^(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):\\s*Error\\:\\s*(?P<message>.*)$",
    "^(.*?):(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):\\s*Error\\:\\s*(?P<message>.*)$",
    "^Error:[\\s\\t]+(?P<message>.*)",
    "^\\s*(Z:)?(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):(?P<column>\\d+):\\s*fatal\\serror\\:\\s*(?P<message>.*)$",
    "^\\s*(Z:)?(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):(?P<column>\\d+):\\s*error\\:\\s*(?P<message>.*)$",
    "^(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):(?P<column>\\d+):\\s*error\\:\\s*(?P<message>.*)$",
    "^(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):\\s*error\\:\\s*(?P<message>.*)$",
    "^(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):\\s\\*\\*\\*\\s(?P<message>.*)",
    "^.*error\\:\\s*(?P<message>.*)\\sat\\s+(Z:)?(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+)$",
    "^.*error\\:\\s*(?P<message>.*)\\sat\\s+(Z:)?(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*)\\sline\\s(?P<line>\\d+)$",
    "^.*error\\:\\s*(?P<message>.*)$",
    "^make\\:\\s+\\*\\*\\*\\s+(?P<message>.*)\\.\\s+Stop\\.$"
]

warning_regex: list[str] = [
    "^(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):(?P<column>\\d+):\\s*warning\\:\\s*(?P<message>.*)$",
    "^WARNING:(.*?)\\s-\\s\"(\\.\\.\\/\\.\\.\\/)?(Z:)?(?P<file>.*?)\"\\s[Ll]ine\\s(?P<line>\\d+)[\\:\\.]\\s(?P<message>.*)",
    "^WARNING:(.*?)\\s-\\s(?P<message_pre>.*?)((\\$n\\$)|(\\s))\\[(Z:)?(?P<file>.*?)\\((?P<line>\\d+)\\)\\]((\\:\\s)|(.\\$n\\$))(?P<message>.*)",
    "^WARNING:(.*?)\\s-\\s(?P<message>.*?)((\\$n\\$)|(\\s))\\[(Z:)?(?P<file>.*?)\\((?P<line>\\d+)\\)\\]",
    "^WARNING:(.*?)\\s-\\s(?P<message>.*)",
    "^WARNING\\s-\\s(.*?)\\:\\s+(Z:)?(?P<file>.*)\\((?P<line>\\d+), (\\d+)\\)\\:\\s(?P<message>.*)",
    "^WARNING\\s-\\s(.*?)\\:\\s+(Z:)?(?P<file>.*)\\((?P<line>\\d+)\\)\\:\\s(?P<message>.*)",
    "^WARNING\\s-\\s(.*?)\\:\\s+(Z:)?(?P<file>.*)\\:\\s(?P<message>.*)",
    "^WARNING\\s-\\s(.*?)\\:\\s+(?P<message>.*)",
    "^(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):\\s*Warning\\:\\s*(?P<message>.*)$",
    "^(.*?):(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):\\s*Warning\\:\\s*(?P<message>.*)$",
    "^\\s*(Z:)?(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):(?P<column>\\d+):\\s*warning\\:\\s*(?P<message>.*)$",
    "^(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):\\s*warning\\:\\s*(?P<message>.*)$",
    "^.*warning\\:\\s*(?P<message>.*)\\sat\\s+(Z:)?(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+)$",
    "^.*warning\\:\\s*(?P<message>.*)$",
    "^Warn\\s:[\\s\\t]+(?P<message>.*)"
]

message_regex: list[str] = [
    "^(?P<message>Synthesizing Unit <.*>)\\..*$",
    "^INFO:(.*?)\\s-\\s\"(\\.\\.\\/\\.\\.\\/)?(Z:)?(?P<file>.*?)\"\\s[Ll]ine\\s(?P<line>\\d+)[\\:\\.]\\s(?P<message>.*)",
    "^INFO:(.*?)\\s-\\s(?P<message_pre>.*?)((\\$n\\$)|(\\s))\\[(Z:)?(?P<file>.*?)\\((?P<line>\\d+)\\)\\]((\\:\\s)|(.\\$n\\$))(?P<message>.*)",
    "^INFO:(.*?)\\s-\\s(?P<message>.*?)((\\$n\\$)|(\\s))\\[(Z:)?(?P<file>.*?)\\((?P<line>\\d+)\\)\\]",
    "^INFO:(.*?)\\s-\\s(?P<message>.*)",
    "^INFO:(?P<message>.*)",
    "^Info\\s:[\\s\\t]+(?P<message>.*)",
    "^(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):\\s*note\\:\\s*(?P<message>.*)$",
    "^make(\\[\\d+\\])?:\\s(?P<message>.*)$",
    "^(?P<message>XAnalyzing\\s .*)$",
]

# "^\\s*(Z:)?(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):(?P<column>\\d+)\\:\\s*(?P<message>.*)$",
# "^\\s*(Z:)?(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):\\s*(?P<message>.*)$",
# "^(?P<message>.*)$"

hide_regex: list[str] = [
    "^WARNING\\s-\\ssynthesis:\\sSkipping\\spad\\sinsertion\\son\\sspi_.*\\sdue\\sto\\sblack_box_pad_pin\\sattribute.$",
    "^WARNING\\s-\\s(.*?)\\:\\s+(Z:)?(?P<file>.*)\\((?P<line>\\d+)\\)\\:\\sreplacing\\sexisting\\snetlist\\s.*",
    "^WARNING:Xst:737\\s",
    "^WARNING:Xst:1293\\s",
    "^WARNING:Xst:1710\\s",
    "^WARNING:Xst:1895\\s",
    "^WARNING:Xst:1896\\s",
    "^INFO:Xst:2261\\s",
    "^In\\sfile\\sincluded\\sfrom\\s(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):",
    "^[\\s]*from\\s(Z:)?(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):",
    "^\\s*from\\s(?P<file>[\\/\\w\\d:\\\\\\.-][\\/\\s\\d\\w:\\\\\\.-]*):(?P<line>\\d+):",
    "^make(\\[\\d+\\])?:\\sNothing\\sto\\sbe\\sdone\\sfor\\s(?P<message>.*)$",
    "^[A-Za-z]+\\s[A-Za-z]+\\s[0-9]+\\s[0-9]+\\:[0-9]+\\:[0-9]+\\s[0-9]+$",
    "^Start\\sNBR\\s",
    "^.*std_logic_arith\\.vhdl.*\\(assertion\\swarning\\)\\:",
    "^make\\[2\\]:\\s`.*' is up to date.$"
]

line_regex: list[str] = [
    "^Driver\\s(?P<message_pre>[0-9]+\\:)\\soutput\\ssignal\\s(?P<message>.*)\\.$"
]

class OutputTypes(StrEnum):
    CLion: str = "clion"
    Sublime: str = "sublime"

class SeverityTypes(StrEnum):
    Info: str = "note"
    Warning: str = "warning"
    Error: str = "error"
    FatalError: str = "fatal_error"

class Message:
    def __init__(self: Self, severity: SeverityTypes, match: Match, message_type: str) -> None:
        self.severity: SeverityTypes = severity
        self.message_type: str = message_type

        groups: dict[str, Optional[str]] = match.groupdict()
        self.message_pre: Optional[str] = groups.get("message_pre", None)
        self.message: Optional[str] = groups.get("message", None)
        self.file: Optional[str] = groups.get("file", None)
        if self.file is not None:
            self.file = self.casify_path(self.file)
        self.line: Optional[str] = groups.get("line", None)
        self.column: Optional[str] = groups.get("column", "0")

    def casify_path(self: Self, path: str) -> str:
        path = os.path.abspath(path)
        ref_path_elements: list[str] = path.split(os.path.sep)
        for i, e in enumerate(ref_path_elements):
            ls: str = os.path.sep.join(ref_path_elements[:i + 1])
            if ls.strip() == "":
                continue
            for d in os.listdir(os.path.dirname(ls)):
                if d.lower() == e:
                    ref_path_elements[i] = d;
                    break;
        return os.path.sep.join(ref_path_elements)

    def __str__(self: Self) -> str:
        line : str = ""
        if self.file is not None:
            line += f"{self.file}:"
            if self.line is not None:
                line += f"{self.line}:{self.column}:"
            line += " "
        line += f"{self.severity}: "
        if self.message_pre is not None:
            line += f"{self.message_pre} "
        line += f"{self.message}"
        return line

def make_messages(type : str, matches : Iterable[tuple[SeverityTypes, Match]]) -> Iterable[Message]:
    for severity, match in matches:
        yield Message(severity, match, type)

def filter_message_categories(error_patterns : list[re.Pattern], warning_patterns : list[re.Pattern], info_patterns : list[re.Pattern], lines : Iterable[str]) -> Iterable[tuple[SeverityTypes, Match]]:
    for line in lines:
        for pattern in error_patterns:
            match = pattern.match(line)
            if match is not None:
                yield SeverityTypes.Error, match
                break
        else:
            for pattern in warning_patterns:
                match = pattern.match(line)
                if match is not None:
                    yield SeverityTypes.Warning, match
                    break
            else:
                for pattern in info_patterns:
                    match = pattern.match(line)
                    if match is not None:
                        yield SeverityTypes.Info, match
                        break

def filter_excludes(patterns : list[re.Pattern], lines : Iterable[str]) -> Iterable[str]:
    for line in lines:
        for pattern in patterns:
            if pattern.match(line):
                break
        else:
            yield line

def combine_lines(patterns : list[re.Pattern], lines : Iterable[str]) -> Iterable[str]:
    last_line: str = ""
    for line in lines:
        for pattern in patterns:
            if pattern.match(line):
                last_line += line
                break
        else:
            yield last_line
            last_line = line
    yield last_line

def strip_eol(lines : Iterable[str]) -> Iterable[str]:
    for line in lines:
        yield line.rstrip()

def process_output(in_stream, format: OutputTypes):
    for message in make_messages(format,
                                 filter_message_categories([re.compile(p) for p in error_regex],
                                                           [re.compile(p) for p in warning_regex],
                                                           [re.compile(p) for p in message_regex],
                                                           combine_lines([re.compile(p) for p in line_regex],
                                                           filter_excludes([re.compile(p) for p in hide_regex],
                                                           strip_eol(in_stream))))):
        print(message)

if __name__ == '__main__':
    import argparse
    import sys
    argv = list(sys.argv[1:])
    try:
        command_start = argv.index("--")
        command = argv[command_start + 1:]
        argv = argv[:command_start]
    except:
        command_start = -1

    parser: argparse.ArgumentParser = argparse.ArgumentParser()
    parser.add_argument('-f', '--format', help="The format to output", default=OutputTypes.CLion, choices=[OutputTypes.CLion, OutputTypes.Sublime])
    parser.add_argument("-e", "--ignore-errors", action="store_true", help="Ignore errors")
    args = parser.parse_args(argv)
    if command_start >= 0:
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        process_output(process.stdout, args.format)
        if args.ignore_errors:
            process.wait()
            sys.exit(0)
        else:
            sys.exit(process.wait())
    else:
        process_output(sys.stdin, args.format)
        sys.exit(0)