# Hel Industries Hybrid Build System

## Description

This repository contains a multi-platform build system for building hybrid FPGA and software
projects, including building and running tests and building additional build tools during the
build process. It can leverage Arduino cores, installations and drivers for faster bootstrapping
of projects and to minimize initial configuration, but can also move to build completely bare-
metal or against any RTOS if required. To run FPGA builds using the Lattice Diamond or Xilinx ISE
toolchains on macOS, this build system can use Wine64 or CrossOver. For Windows and Linux, it
supports running the toolchains natively. This build system is not meant for beginners, it is not
meant to be simple or intuitive. It is targeted at advanced and professional software developers,
who require access to extra controls like what actually goes in the build system, what happens in
the main loop without all this setup() and loop() madness, features like triggering hard resets
and logic analyzers after builds or integration or support for IDEs for larger projects with
more complicated project structures and proper support for debugging support with breakpoints
and variable watches as well as access to features like advanced code completion and AI like
GitHub Code Copilot for even faster results.

## Features

* Build hybrid FPGA and software projects
* Perform a reset on your board (using a user-defined resetter command) before upload
* Supports both JTAG as well as board-specific upload strategies (if JTAG is available)
* Supports both native and Wine64/CrossOver toolchains in case native is not available, JTAG is
recommended
* Trigger a logic-analyzer via special script shortly before upload
* Support for module builds, that use the same build setup, i. e. for Arduino module and core builds
* Support for Makefile-based dependencies, that use their own build setup with the following types:
  * **Lib:** Libraries, required for compilation of the main target
  * **Exec:** Executable code for the main target, that may be loaded into memory
  * **Gateware:** Gateware to be deployed to the FPGA
  * **Tests:** Test build and execution, always targeting the build platform
  * **Tools:** Tools builds, always targeting the build platform
  * **Make:** All other Makefile-based build targets, currently used to build assets
* Compatible with multiple IDEs
  * **CLion** tested and working nicely
  * **Sublime Text 3/4** tested and fully working, use Advanced Build System for best results
  * **Xcode** tested a while a go
  * **Eclipse** previously worked well
  * Any other IDE with Makefile and parsing GCC and Clang style errors support should work as well,
but were not tested explicitly.
* VHDL supported well, Verilog working on a compatibility-module basis
* Simulator support using ISim or GHDL
* ARMCC/CMSIS integration is available to some extend, but not included in the public release due to
licensing concerns, via Wine even on Linux and macOS
* New compilers and toolchains like AVR can easily be added

## Supported devices and platforms:

The supported target devices are listed below, the configurations can be found in the *Targets* directory.
New devices can easily be added there, PRs are welcome. Devices with both an CPU and an FPGA should be split
into CPU and FPGA configurations.

### Platforms

* Native host platform (tested and currently working)
* ARM (tested ages ago, might need work)
* ESP32 (tested and currently working)
* Xilinx ISE (tested ages ago, might need work, must install in default location)
* Lattice Diamond (tested and currently working, must install in default location)
* Yosys+GHDL (tested ages ago, might need work)
* GHDL (tested and currently working)

Note, that Xilinx Vivado isn't yet supported, as I was not able to install it on macOS for the time being and
had no reason to look into why.

### CPU targets

* PJRC Teensy 3.2 (tested ages ago, might need work)
* PJRC Teensy 3.6 (tested ages ago, might need work)
* PJRC Teensy LC (prepared but untested)
* Adafruit Feather M0 (prepared but untested)
* Adafruit Feather ESP32S3 (tested and currently working)
* Adafruit Feather ESP32S2 (prepared but untested)
* Adafruit Feather ESP32 (prepared but untested)
* Radiona ULX3S ESP32 (prepared but untested, requires addition of passthrough upload before programming
the ESP32)

### FPGA targets

* Xess Xula2-LX25 (tested ages ago, might need work)
* 1BitSquared OrangeCrab-85f (tested and currently working)
* Radiona ULX3S-85f (tested and currently working)

## Requirements

* GNU Make 4.2+
* Bash 4.0+
* Python 3.8+
* Arduino and hardware targets (if you want to use Arduino cores and libraries to quickly bootstrap your project)
* OpenOCD (if no Arduino installation present, ESP32 fork recommended for additional support)
* Xilinx ISE or Lattice Diamond (if you want to build FPGA gateware)
* Wine64 or CrossOver (if you want to build FPGA gateware on macOS)
* GHDL and GTKWave (if you want to simulate your gateware)
* Yosys (if you want to synthesize your gateware for Lattice devices using open-source tools)
* `pip install mypy pytest`

## Setup

To configure the build system, create a *Config.mk* file in the repositories root directory. You can find an example
in *Documents/Config.examples.mk*. Can check the *Common.mk* and *Toolchain.mk* for variables, that are already
available at that step to help you.

## Usage

Projects will require a **Makefile** set up. The Makefile should look something like the following examples:

### CPU-based core project, triggering FPGA dependencies

The project structure for the examples is as follows:

    Root
    |- Build
    |- Makefile, that just runs the sub-target in Source
    |- Source
    |   |- Makefile
    |   \- main.cpp
    |- MyLib
    |   |- Makefile
    |   \- lib.cpp
    \- Gateware
        |- Makefile
        \- gateware.vhd

```Makefile
# Make sure to define targets first, so included targets don't override the target, being executed without arguments
# Perform all builds here
all: dependencies binary-cpu stats-cpu

# Perform all builds
install: all upload-cpu upload-fpga-late

# Perform all cleanups
clean: clean-dependencies clean-cpu

.PHONY: all install recover clean

# Set up the basic configuration
TARGET = MyTarget
BUILD_DIR = ../Build
DEVICES_DIR := $(abspath Boards)
CPU_DEVICE = feather-esp32s3
CPU_USE_JTAG = yes
FPGA_DEVICE = orangecrab-85f
FPGA_USE_JTAG = yes
USE_ARDINO_CORE = yes
ARDUINO_VARIANT_NAME = feather-esp32s3-tft
# Use GNU C++17 if using the SPI lib, the ESP version uses non-standard macros
CXXFLAGS += -gnu++17

HEADERS := $(wildcard *.h **/*.h)
C_FILES := $(wildcard *.c **/*.c)
CPP_FILES := $(wildcard *.cpp **/*.cpp)
INO_FILES := $(wildcard *.ino)
ASM_FILES := $(wildcard *.s **/*.s)

# Project definition includes, do this first, so paths like CORE_LIB_PATH are defined
include ../BuildSystem/BuildSystem.mk
include $(MAKE_INC_PATH)/CPUBoards.mk

# Define Arduino modules and dependencies
MODULES += SPI:$(CORE_LIB_PATH)/SPI/src
MODULES += Adafruit_ST7789:$(ARDUINO_LIBRARIES_DIR)/Adafruit_ST7735_and_ST7789_Library
DEPENDENCIES += Lib:MyLib:../MyLib
DEPENDENCIES += Gateware:MyGateware:../MyGateware

# Project target and post-config includes, do these only after you defined all remaining configs
include $(MAKE_INC_PATH)/Dependencies.mk
include $(MAKE_INC_PATH)/Modules.mk
include $(MAKE_INC_PATH)/CPUTargets.mk
include $(MAKE_INC_PATH)/Targets.mk

# This is an example for uplaoding gateware late, so any compile errors and any other issues
# happen before, so you don't waste time on waiting for a gateware or dependency upload to later
# discover, your CPU code doesn't compile. Your code should honour the NO_GATEWARE_UPLOAD variable.
NO_GATEWARE_UPLOAD = yes
upload-fpga-late:
ifneq ($(strip $(NO_GATEWARE_DEPS)),yes)
    @# Gateware wasn't installed during dependency build, so install it now. Include
    @# this before the CPU upload for debugging to be able to break on init properly
    $(V)$(MAKE) --directory=$(FRAMEWORK_PATH)/GPU --file=$(FRAMEWORK_PATH)/GPU/Makefile install
endif
```

### FPGA-based project

```Makefile
# Make sure to define targets first, so included targets don't override the target, being executed without arguments
all: layout

install: upload-fpga

simulate: ghdl

clean: clean-fpga clean-ghdl

.PHONY: all install simulate clean

# Project config
FPGA_TARGET := my_target
FPGA_DEVICE = orangecrab-85f
FPGA_USE_JTAG = yes
# Some rom definitions, they need to either exist or have a python or bash-based file to generate them
ROMS = rom/$(FPGA_TARGET)_rom.txt rom/$(FPGA_TARGET)_ram.txt rom/$(FPGA_TARGET)_host_ram.txt rom/$(FPGA_TARGET)_tb.txt
BUILD_DIR = ../Build

# Simulation setup
GHDL_TIMEOUT = 1000ns
GHDL_WORK = work

# Include configs now, containing additional variables
include ../../BuildSystem/BuildConfig.mk
include $(PROJECT_PATH)/../../Makefiles/BuildSystem.mk
include $(MAKE_INC_PATH)/FPGABoards.mk

# Add any dependencies here
DEPENDENCIES += Make:MyAssets:Assets

# Include targets now, containing the actual build rules, note, that this build uses GHDL for simulation
include $(MAKE_INC_PATH)/FPGATargets.mk
include $(MAKE_INC_PATH)/GHDLToolchain.mk
include $(MAKE_INC_PATH)/GHDLTargets.mk
```

With your *Makefile* set up, you can run `make cfg-cpu` or `make cfg-fpga` to get an idea of how your build
is configured and whether your build will perform as expected. To follow the build process in detail and
debug issues, that arise, you can run `make VERBOSE=1` to get a detailed log of the build process.

### CLion Setup

CLion is a very good IDE for embedded development, it supports Makefile-based projects well, has very good
introspection and can use the typical flags to inspect Makefiles. It has very good debugging support and has
a dedicated plugin for connecting to OpenOCD. It supports AI tools like GitHub Code Copilot very well. Its
VHDL support is currently not very good, but it is possible to use it for VHDL development and limited to
rather bad syntax highlighting, Copilot can however mitigate a lot of its shortcomings. The following setup
is highly recommended once you set up your Makefile:

- Install the OpenOCD plugin (not the ESP32 one, even if you are using an ESP32, it is broken).
- For nice Serial support, install the Arduino plugin.
- Set project updates to update any time the Makefile is changed from anywhere.
- Remove all but the *all*, *install*, *clean* and *simulate* from the run target.
- Configure the all target to use /usr/bin/true (or the Windows pendant) as an executable, then replace the pre-run
task to point at the *install* task. Now you can use the build and run buttons conveniently.
- Move the Run Window to a corner, it is going to run the /usr/bin/true executable anyway and would only interfere
with the Serial Monitor coming to the foreground.
- Set up a separate OpenOCD target using the all command, set init to reset and download to never, then replace the
pre-run task to point to *install* as well. Only use this target for debugging when using an ESP32, as the non-
debugging version will likely crash the device.
- If you want to build the product and libraries from adjacent directory trees, you can also modify the project root
- In case of a VHDL (sub)project, create another target for the all rule (if you have an CPU all rule already),
and this time replace the pre-run task to point to the *simulate* task and the executable to /usr/bin/true, now you
can compile your code or run the simulation using the appropriate buttons in the IDE. Build reports can be found in
your build directory, so make sure your project root is well chosen to allow access form the IDE.

### Sublime Text 3/4 Setup

Sublime Text 3/4 is a very good editor for basic embedded development and with the VHDL Mode plugin provides
very good support for VHDL packages, including definition navigation, reasonably good auto-complete, very good
syntax highlighting and a very good VHDL linter. It supports AI tools like GitHub Code Copilot reasonably well.
It does however not provide a good debugging solution. Sublime Text already provides a build system for
Makefiles, but it doesn't support the simulation for FPGA, if required, it can be added to a new build system
specification as seen below.

```json
{
    "shell_cmd": "make",
    "working_dir": "${project_path:${folder}}",
    "variants": [
        { "name": "Install", "shell_cmd": "make install" },
        { "name": "Clean", "shell_cmd": "make clean" },
        { "name": "Simulate", "shell_cmd": "make simulate" }]
}
```

Alternatively, you can and should install the [AdvancedBuildSystem](https://github.com/hi-pauls/sublime-advanced-builder)
package for a more IDE-like feel of the build process. In either case, make sure you have shortcuts set up for executing
the respective build variants.

## License

This project is licensed under the MIT license, see LICENSE for details.

## Naming convention

- Target: The build target, usually used for the name of a binary or project
- Module: A single file or a group of files that are compiled together within the same Makefile target
- Core: The core module for a specific CPU or FPGA
- Dependency: A separate sub-build, running in a separate Makefile
- Toolchain: A manufacturer-specific toolchain, like the ESP-IDF or the STM32Cube****
- Architecture: The architecture of the CPU or FPGA, defining the instruction set and core features
- CPU: The CPU core, defining core features and peripherals
- FPGA: The FPGA, defining core features and peripherals
- Device: The carrier of a CPU or FPGA, usually a board or a module, but may also be a complete laptop
- System: The complete, integrated system, containing 0 or more CPUs and FPGAs, as well as other components
- Platform: A group of systems following similar designs and components and supporting the same targets
- Project: A solution made of one or more targets

## Variables
Due to the way Makefiles handle variables and because we want to have passing be as intuitive as possible, variables
are split into five groups, common default variables, settings, parameter variables, configuration variables and
special module and dependency variables.

### Default variables
These are the well-known variables, used as parameters for build commands. They are what IDEs will use to parse and
process project build options, they will accumulate all options and flags, but should not be passed around between
Makefiles or otherwise outside of platform or target definitions. These are i. e. CFLAGS or LDFLAGS.

### Settings variables
These are variables the Makefile wants to define for its own build, they will be integrated and may override the
values defined in platform or target definitions and will be integrated in the target file as the last step.
These are i. e. CPU_CFLAGS or CPU_LDFLAGS.

### Parameter variables
These variables are specifically meant as parameters for the sub-Makefile, the sub-Makefile is responsible for using
them by: Not doing anything with them and leaving it to the target scripts to integrate them via ?= operators, or
use them in specifically set options when setting or adding their base variable, i. e. via CPU_CFLAGS += $(IN_CFLAGS),
or define a full override, discarding the parameter value.

### Configuration variables ###
These variables are passed through every Makefile, expecting the first version to be the only relevant on, so they
should not be platform-specific and should not differ for different build targets. These variables will not have the
IN_ prefix.

### Special module and dependency variables
These variables are passed specifically to a single module or dependency, they can be specified only in the module
that is also defining the dependency or module as DEPENDENCY_OPTS_<name> or MODULE_OPTS_<name>.

For overriding variables, when a Makefile is called from another Makefile in the build script using a new process,
there is a basic rule: If the Makefile should override a variable in the old Makefile, it needs to set the new
variable by using the ?= or := operator before including *Flags.mk or *Toolchain.mk. If it wants to default to a
value but keep it overridable, it needs to use the ?= operator in the IN_-prefixed variable before including the 
*Flags.mk or *Toolchain.mk and can rely on those scripts to override the value if its underlying value was not
explicitly passed to the Makefile.

## Personal note from the maintainer

Please note, that this is what I use for projects, PRs are welcome, but don't expect this to be fully
functional or documented without you having to check the code for additional variables or other things.
Feel free to add documentation for anything you discover as PRs as well. Should you want to use this
project as a base for your projects, but don't have the specific knowledge or experience, required to
set it up for your use-case, please feel free to get in touch, I am available for hire on a consulting
or development basis.
