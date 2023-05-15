#!/usr/bin/env python3

import os.path
import re
import sys
from collections import OrderedDict

package_re = re.compile("^[\ \t]*package (?P<name>[a-zA-Z0-9_-]+) is[\ \t]*((--).*)?\r?$")
include_re = re.compile("^[\ \t]*use (?P<library>[a-zA-Z0-9_-]+).(?P<package>[a-zA-Z0-9_-]+).[a-zA-Z0-9_-]+;[\ \t]*((--).*)?\r?$")

lse_top_template = """<?xml version="1.0" encoding="UTF-8"?>
<BaliProject version="3.2" title="{top_module}" device="{package}" default_implementation="{top_module}">
    <Options/>
    <Implementation title="{top_module}" dir="{top_module}" description="{top_module}" synthesis="lse" default_strategy="Strategy1">
        <Options def_top="{top_module}" top="{top_module}"/>
"""
lse_sim_only_template = " syn_sim=\"SimOnly\""
lse_lib_option_template = "lib=\"helindustries\""
lse_lib_template = """        <Source name="{source_path}" type="{source_type}" type_short="{source_short}"{sim_only}>
            <Options{lib_opts}/>
        </Source>
"""
lse_bottom_template = """    </Implementation>
    <Strategy name="Strategy" file="{top_module}.sty"/>
</BaliProject>
"""

class HardwareInclude(object):
    def __init__(self, library, name, line):
        super(HardwareInclude, self).__init__()
        self.library = library.lower()
        self.name = name.lower()
        self.line = line

class HardwareModule(object):
    def __init__(self, library, name):
        super(HardwareModule, self).__init__()
        self.library = library
        self.name = name
        self.key = name.lower()
        self.packages = []
        self.requires = []

    def get_path(self):
        return os.path.join(self.library.path, self.name)

    def collect(self):
        path = self.get_path()
        with open(path, "r") as fd:
            content = fd.readlines()

        self.packages = []
        for line in content:
            match = package_re.match(line)
            if match is not None:
                self.packages.append(match.groupdict()["name"].lower())

        index = 0
        self.requires = []
        for line in content:
            index += 1
            match = include_re.match(line)
            if match is not None:
                library = match.groupdict()["library"]
                package = match.groupdict()["package"]
                if package.lower() not in self.packages:
                    self.requires.append(HardwareInclude(library, package, index))

    def __str__(self):
        return self.name

class HardwareLibrary(object):
    def __init__(self, name, path):
        super(HardwareLibrary, self).__init__()
        self.name = name
        self.key = name.lower()
        self.path = path
        self.modules = OrderedDict()
        self.modulesByPackage = OrderedDict()

    def add_module(self, path):
        module = HardwareModule(self, path)
        module.collect()
        self.modules[module.key] = module
        for package in module.packages:
            self.modulesByPackage[package] = module

    def collect(self):
        path = self.path
        if path == "":
            path = "."

        self.modules = OrderedDict()
        self.modulesByPackage = OrderedDict()
        for name in os.listdir(path):
            key = name.lower()
            if key.endswith(".vhd") or key.endswith(".vhdl") or key.endswith(".v"):
                self.add_module(name)

    def __str__(self):
        return "%s:%s" % (self.name, self.path)

    @classmethod
    def parse(cls, in_str):
        return cls(*in_str.split(":", 1))

class HardwareDesignDependencies(object):
    def __init__(self, main_path):
        super(HardwareDesignDependencies, self).__init__()
        self.main_name = os.path.basename(main_path)
        self.libraries = {"work": HardwareLibrary("work", os.path.dirname(main_path))}
        self.dependenciesByFile = OrderedDict()
        self.modules = OrderedDict()
        self.static_paths = []

    def add_library(self, library):
        self.libraries[library.name.lower()] = library

    def add_static_path(self, path):
        self.static_paths.append(path)

    def collect(self):
        for name, library in self.libraries.items():
            library.collect()

        work = self.libraries["work"]
        for path in self.static_paths:
            work.add_module(path)

        module = work.modules[self.main_name.lower()]
        self.dependenciesByFile[module.get_path()] = module
        stack = [module]
        while len(stack) > 0:
            dependency = stack.pop(len(stack) - 1)

            for require in dependency.requires:
                if require.library in self.libraries:
                    if require.library not in self.libraries:
                        sys.stderr.write("ERROR:PRJ - \"%s\" Line %d: Referenced library %s not found.\n" % (dependency.get_path(), require.line, require.library))
                        return 1
                    elif require.name not in self.libraries[require.library].modulesByPackage:
                        sys.stderr.write("ERROR:PRJ - \"%s\" Line %d: Referenced package %s not found.\n" % (dependency.get_path(), require.line, require.name))
                        return 2
                    else:
                        module = self.libraries[require.library].modulesByPackage[require.name]
                        key = module.get_path()

                        if key in self.dependenciesByFile:
                            del(self.dependenciesByFile[key])
                        else:
                            stack.append(module)

                        self.dependenciesByFile[key] = module

        self.dependenciesByFile = OrderedDict(reversed(list(self.dependenciesByFile.items())))
        return 0

    def copy_to(self, path):
        pass

    def write_xilinx(self, path, relative_to):
        with open(path, "w+") as fd:
            for k, v in self.dependenciesByFile.items():
                filetype = ""
                if v.name.endswith(".vhd") or v.name.endswith(".vhdl"):
                    filetype = "vhdl"
                elif v.name.endswith(".v"):
                    filetype = "verilog"

                path = os.path.join(v.library.path, v.name)
                if relative_to != "":
                    path = os.path.relpath(relative_to, path)
                fd.write("%s %s %s\n" % (filetype, v.library.name, path))

    def write_lattice(self, relative_to):
        libname = ""
        dependencies = list(self.dependenciesByFile.values())
        dependencies.sort(key = lambda dependency: dependency.library.name)

        for dependency in dependencies:
            filetype = ""
            if dependency.name.endswith(".vhd"):
                filetype = "-vhd"
            elif dependency.name.endswith(".v"):
                filetype = "-ver"

            path = os.path.join(dependency.library.path, dependency.name)
            if relative_to == "":
                path = os.path.abspath(path)
            else:
                path = os.path.relpath(relative_to, path)

            #if libname != dependency.library.name:
            #    sys.stdout.write("-lib \"%s\" " % dependency.library.name)
            #    libname = dependency.library.name

            if dependency.library.name != "work":
                sys.stdout.write("-lib \"%s\" " % dependency.library.name)
            sys.stdout.write("%s \"%s\"\n" % (filetype, path))

    def write_lse(self, relative_to, package, lpf):
        top_module = self.main_name.rstrip(".vhd").rstrip(".v")
        sys.stdout.write(lse_top_template % {"top_module": top_module, "package": package})

        for k, v in self.dependenciesByFile.items():
            path = os.path.join(v.library.path, v.name)
            if relative_to == "":
                path = os.path.abspath(path)
            else:
                path = os.path.relpath(relative_to, path)

            sim_only = ""
            if path.rstrip(".vhd").rstrip(".v").endswith("_tb"):
                sim_only = lse_sim_only_template

            source_type = ""
            if path.endswith(".vhd"):
                source_type = "VHDL"
            if path.endswith(".v"):
                source_type = "Verilog"

            lib_opts = ""
            if v.library.name != "work":
                lib_opts = lse_lib_option_template % {"lib_opts": v.library.name}
            sys.stdout.write(lse_lib_template % {"source_path": path, "source_type": source_type, "source_short": source_type, "lib_opts": lib_opts, "sim_only": sim_only})

        sys.stdout.write(lse_lib_template % {"source_path": lpf, "source_type": "Logic Preference", "source_short": "LPF", "lib_opts": "", "sim_only": ""})
        sys.stdout.write(lse_bottom_template % {"top_module": top_module})

    def write_yosys(self, relative_to):
        for k, v in self.dependenciesByFile.items():
            path = os.path.join(v.library.path, v.name)
            if relative_to == "":
                path = os.path.abspath(path)
            else:
                path = os.path.relpath(relative_to, path)
            sys.stdout.write("%s %s\n" % (v.library.name, path))

    def write_ghdl(self, relative_to):
        for k, v in self.dependenciesByFile.items():
            path = os.path.join(v.library.path, v.name)
            if relative_to == "":
                path = os.path.abspath(path)
            else:
                path = os.path.relpath(relative_to, path)
            sys.stdout.write("%s %s\n" % (v.library.name, path))

    def print_files(self):
        for k, v in self.dependenciesByFile.items():
            sys.stdout.write(" %s" % v.get_path())

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("main_path", help="Path of the main file.")
    parser.add_argument("-l", "--library", metavar="LIBRARY", default="work", help="Name of the library.", dest="library")
    parser.add_argument("-o", "--outputfile", metavar="FILE", default="", help="Path of the output file.", dest="outputfile")
    parser.add_argument("--xilinx", action="store_true", help="Write Xilinx project", dest="xilinx")
    parser.add_argument("--lattice", action="store_true", help="Write Lattice project", dest="lattice")
    parser.add_argument("--lse", action="store_true", help="Write LSE project", dest="lse")
    parser.add_argument("--ghdl", action="store_true", help="Write GHDL project", dest="ghdl")
    parser.add_argument("--yosys", action="store_true", help="Write YoSYS project", dest="yosys")
    parser.add_argument("--package", metavar="PACKAGE", default="", help="The target package.", dest="package")
    parser.add_argument("--lpf", metavar="LPF", default="", help="The target package.", dest="lpf")
    parser.add_argument("-p", "--printdeps", action="store_true", help="Print dependencies to stdout.", dest="printdeps")
    parser.add_argument("-c", "--copy", action="store_true", help="Copy project dependencies to output directory, requires -o.", dest="copy")
    parser.add_argument("-i", "--include", metavar="NAME:PATH", action="append", help="Name and path of the included library.", dest="include")
    parser.add_argument("-s", "--static", metavar="PATH", action="append", help="Add this static path to the work module", dest="static")
    parser.add_argument("-a", "--absolute", action="store_true", help="Use absolute file paths", dest="absolute")
    args = parser.parse_args()

    #outputfile = args.outputfile
    #if outputfile == "":
    #    outputfile = re.sub("\.(vhd)|(v)$", ".prj", args.main_path)

    deps = HardwareDesignDependencies(args.main_path)
    if args.include is not None:
        for include in args.include:
            deps.add_library(HardwareLibrary.parse(include))

    if args.static is not None:
        for static in args.static:
            deps.add_static_path(static)
    if deps.collect() != 0:
        sys.exit(1)

    basedir = os.path.dirname(args.outputfile)
    if args.copy and basedir != "":
        deps.copy_to(basedir)
    else:
        basedir = os.path.dirname(args.main_path)

    if args.absolute:
        basedir = ""
    if args.xilinx and args.outputfile != "":
        deps.write_xilinx(args.outputfile, basedir)
    if args.lattice:
        deps.write_lattice(basedir)
    if args.ghdl:
        deps.write_ghdl(basedir)
    if args.yosys:
        deps.write_yosys(basedir)
    if args.lse:
        if args.package == "":
            sys.stderr.write("Missing package argument")
            sys.exit(1)
        if args.lpf == "":
            sys.stderr.write("Missing lpf argument")
            sys.exit(1)
        deps.write_lse(basedir, args.package, args.lpf)
    if args.printdeps:
        deps.print_files()
