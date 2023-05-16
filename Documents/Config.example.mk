# This example uses an existing Arduino installation to forego the need to configure individual
# toolchains. The Arduino installation is expected to be in the default location on macOS. It is
# possible to instead specify all compiler and SDK paths to not rely on an Arduino implementation.

# The Arduino installation path
ARDUINO_PATH ?= /Applications/Arduino.app/Contents/Java
# The Arduino user path
ARDUINO_USERPATH ?= $$HOME/Library/Arduino15

# The path to the FPGA base library (i. e. HelIndustriesLib, containing platform and board specific directories)
# The library is required to have a boards sub-directory with a .vhd file for each board, you are supporting and
# a platforms directory, containing lattice, xilinx and other target platforms. You can use the Hel Industries
# core library for boards, supported by this build system.
FPGA_BASE_LIBRARY_PATH ?= $(PROJECTS_PATH)/HelIndustriesLib

# The Wine instance to use to run the Xilinx ISE toolchain
#LATTICE_WINE_EXEC ?= /Applications/Wine.app/Contents/Resources/wine/bin/wine64
# The Wine instance base path to use to run the Lattice Diamond toolchain
LATTICE_WINE_USE_CROSSOVER ?= yes
# The prefix, the Diamond toolchain is installed in
LATTICE_WINEPREFIX ?= $(WINE_BOTTLE_PATH)/LatticeDiamond
# The base dir, on macOS must start with the Wine prefix
LATTICE_BASE_DIR ?= $(LATTICE_WINEPREFIX)/drive_c/lscc/diamond/3.12
# The pre-compiled Lattice libraries for GHDL and Yosys
GHDL_LATTICE_LIB ?= $(TOOLCHAIN_PATH)/LatticeLib/ecp5u/v93

# The Wine instance to use to run the Xilinx ISE toolchain
#XILINX_ISE_WINE_EXEC ?= /Applications/Wine.app/Contents/Resources/wine/bin/wine64
# The prefix, the Xilinx ISE toolchain is installed in
XILINX_ISE_WINEPREFIX ?= $(WINE_BOTTLE_PATH)/XilinxISE
# The base dir, on macOS must start with the Wine prefix
XILINX_ISE_BASE_DIR ?= $(XILINX_ISE_WINEPREFIX)/drive_c/Xilinx/14.7/ISE_DS
# The pre-compiled Xilinx libraries for GHDL and Yosys
GHDL_XILINX_ISE_LIB ?= $(TOOLCHAIN_PATH)/XilinxLib/unisim/v93

# The Yosys installations binary path
YOSYS_BIN_PATH ?= $(TOOLCHAIN_PATH)/FPGA/bin
# The path to the Yosys GHDL plugin
YOSYS_GHDL_PLUGIN ?= $(TOOLCHAIN_PATH)/ghdl-yosys-plugin
# The path to the GHDL executable
GHDL = "/opt/homebrew/bin/ghdl"
# The path to the GTKWave binary
GTKWAVE = "/Applications/GtkWave.app/Contents/Resources/bin/gtkwave"

# The command of a tool, that triggers a reset on the development hardware. This executes before uploads to put
# the MCU into a state, where it accepts uploads again, if necessary. May be required by some Arduino boards.
# Will run on ESP32 boards as well as Teensy uploads by default, in other situations, use the resetter target.
RESETTER_CMD ?= /usr/bin/env python3 "$(MAKE_INC_PATH)/Tools/Resetter/teensy_reset.py)" $(RESET_PORT)
# The command of a tool, that triggers your favourite logic analyzer (Saleae Logic, Sigrok, etc.)
RUN_LOGIC_CMD ?= bash "$(MAKE_INC_PATH)Tools/Logic/run_logic.sh"

# Some board-specific settings

# The path to the XuLA2 specific libraries
XULALIB_PATH ?= $(EMBEDDED_HOME)/XuLA2/Projects/XuLALib
# The path to the XSLoad tool for use with the XuLA2 board
XSLOAD ?= "/usr/local/bin/xsload"

# The path to the passthrough binaries for the ULX3S board. They can be downloaded from the ULX3S repository.
ULX3S_PASSTHROUGH_BIN_PATH = $(EMBEDDED_HOME)/Boards/ULX3S/Binaries/passthru
