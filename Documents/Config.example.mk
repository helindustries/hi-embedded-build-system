# --- The example ---
# This example uses an existing Arduino installation to forego the need to configure individual
# toolchains. The Arduino installation is expected to be in the default location on macOS. It is
# possible to instead specify all compiler and SDK paths to not rely on an Arduino implementation.

ifeq ($(strip $(PLATFORM_ID)),windows)
    # The Arduino installation path
    ARDUINO_PATH ?= C:/Program Files (x86)/Arduino/java
    # The Arduino user path
    ARDUINO_USERPATH ?= C:/Users/pschulze/AppData/Local/Arduino15
    # The path to the Qt toolchain
    QT_TOOLCHAIN_PATH ?= C:/Program Files (x86)/Qt/6.8.1/clang_64

	# The path to the Lattice Diamond installation
    LATTICE_BASE_DIR ?= C:/lscc/diamond/3.12
    # The path to the Xilinx ISE installation
    XILINX_BASE_DIR ?= C:/Xilinx/14.7/ISE_DS

    # The path to the GHDL executable
    GHDL = "C:/Program Files/GHDL/ghdl.exe"
    # The path to the GTKWave binary
    GTKWAVE = "C:/Program Files/GtkWave/gtkwave.exe"
    # The path to the XSLoad tool for use with the XuLA2 board
    XSLOAD ?= "C:/Program Files/Python/bin/xsload"

	# The prefix for the LLVM toolchain
    LLVM_PREFIX := C:/Program Files/LLVM/bin
    	# The prefix for the GCC toolchain
    GCC_PREFIX := C:/Program Files/GCC/bin
else
ifeq ($(strip $(PLATFORM_ID)),linux)
    ARDUINO_PATH ?= $(HOME)/.local/share/arduino/Java
    ARDUINO_USERPATH ?= $(HOME)/.config/Arduino15
    QT_TOOLCHAIN_PATH ?= /usr/lib/qt6

    LATTICE_BASE_DIR ?= $(HOME)/.local/share/lscc/diamond/3.12
    XILINX_BASE_DIR ?= $(HOME)/.local/share/xilinx/14.7/ISE_DS

    GHDL = "/usr/bin/ghdl"
    GTKWAVE = "/usr/bin/gtkwave"
    XSLOAD ?= "/usr/local/bin/xsload"

    LLVM_PREFIX := /usr
    GCC_PREFIX := /usr
else
    ARDUINO_PATH ?= /Applications/Arduino.app/Contents/Java
    ARDUINO_USERPATH ?= /Users/pschulze/Library/Arduino15
    QT_TOOLCHAIN_PATH ?= /Users/Shared/Qt/6.8.1/macos

    #LATTICE_WINE_EXEC ?= /Applications/Wine.app/Contents/Resources/wine/bin/wine64
    LATTICE_WINE_USE_CROSSOVER ?= yes
    LATTICE_WINEPREFIX ?= /Users/pschulze/Library/Application Support/CrossOver/Bottles/LatticeDiamond
    LATTICE_BASE_DIR ?= $(LATTICE_WINEPREFIX)/drive_c/lscc/diamond/3.12

    # The Wine instance to use to run the Xilinx ISE toolchain
    #XILINX_WINE_EXEC ?= /Applications/Wine.app/Contents/Resources/wine/bin/wine64
    XILINX_WINE_USE_CROSSOVER ?= yes
    XILINX_WINEPREFIX ?= /Applications/XilinxISE.app/Contents/Resources/wineprefix
    XILINX_BASE_DIR ?= $(XILINX_WINEPREFIX)/drive_c/Xilinx/14.7/ISE_DS

    GHDL ?= "/opt/homebrew/bin/ghdl"
    GTKWAVE ?= "/Applications/GtkWave.app/Contents/Resources/bin/gtkwave"
    XSLOAD ?= "/opt/homebrew/bin/xsload"

    LLVM_PREFIX := /usr
    GCC_PREFIX := /usr
endif
endif

# The path to the FPGA base library (i. e. HelIndustriesLib, containing platform and board specific directories)
# The library is required to have a boards sub-directory with a .vhd file for each board, you are supporting and
# a platforms directory, containing lattice, xilinx and other target platforms. You can use the Hel Industries
# core library for boards, supported by this build system.
FPGA_BASE_LIBRARY_PATH ?= $(PROJECTS_PATH)/HelIndustriesLib

# The pre-compiled Lattice libraries for GHDL and Yosys
GHDL_LATTICE_LIB ?= $(TOOLCHAIN_PATH)/LatticeLib/ecp5u/v93
# The pre-compiled Xilinx libraries for GHDL and Yosys
GHDL_XILINX_ISE_LIB ?= $(TOOLCHAIN_PATH)/XilinxISELib/unisim/v93

# The Yosys installations binary path
YOSYS_BIN_PATH ?= $(TOOLCHAIN_PATH)/FPGA/bin
# The path to the Yosys GHDL plugin
YOSYS_GHDL_PLUGIN ?= $(TOOLCHAIN_PATH)/ghdl-yosys-plugin

# The command of a tool, that triggers a reset on the development hardware. This executes before uploads to put
# the MCU into a state, where it accepts uploads again, if necessary. May be required by some Arduino boards.
# Will run on ESP32 boards as well as Teensy uploads by default, in other situations, use the resetter target.
RESETTER_CMD ?= python3 "$(MAKE_INC_PATH)/Tools/TeensyResetter/teensy_reset.py)" $(RESET_PORT)
# The command of a tool, that triggers your favourite logic analyzer (Saleae Logic, Sigrok, etc.)
RUN_LOGIC_CMD ?= bash "$(MAKE_INC_PATH)/Tools/Logic/run_logic.sh"

# Some board-specific settings

# The path to the XuLA2 specific libraries
XULALIB_PATH ?= $(EMBEDDED_HOME)/XuLA2/Projects/XuLALib

# The path to the passthrough binaries for the ULX3S board. They can be downloaded from the ULX3S repository.
ULX3S_PASSTHROUGH_BIN_PATH = $(EMBEDDED_HOME)/Boards/ULX3S/Binaries/passthru
