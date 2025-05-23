FPGA_TOOLCHAIN := lattice
FPGA_DEPLOY_TARGET := $(FPGA_TARGET).$(FPGA_DEVICE).bit

LATTICE_BIN_DIR := $(LATTICE_BASE_DIR)/bin/nt64
LATTICE_TOOLS_DIR :=  $(LATTICE_BASE_DIR)/ispfpga/bin/nt64
LATTICE_SYNTHESIS := "$(LATTICE_TOOLS_DIR)/synthesis.exe"
LATTICE_MAP := "$(LATTICE_TOOLS_DIR)/map.exe"
LATTICE_TRCE := "$(LATTICE_TOOLS_DIR)/TRCE.exe"
LATTICE_BITGEN := "$(LATTICE_TOOLS_DIR)/bitgen.exe"
LATTICE_MPARTRCE := "$(LATTICE_BIN_DIR)/mpartrce.exe"
LATTICE_DDTCMD := "$(LATTICE_BIN_DIR)/ddtcmd.exe"

LATTICE_SYNTHESIS_OPTS =

ifeq ($(strip $(PLATFORM_ID)),macos)
    ifeq ($(strip $(LATTICE_WINE_USE_CROSSOVER)),yes)
        LATTICE_WINE_BASE_PATH ?= /Applications/CrossOver.app/Contents/SharedSupport/CrossOver
        LATTICE_WINE := "$(LATTICE_WINE_BASE_PATH)/bin/wine" --bottle $(shell basename "$(LATTICE_WINEPREFIX)")
    else
        LATTICE_WINE := WINEPREFIX="$(LATTICE_WINEPREFIX)" "$(LATTICE_WINE_BASE_PATH)/bin/wine64"
    endif

    LATTICE_NATIVE_BASE_DIR := $(subst $(LATTICE_WINEPREFIX)/drive_c,c:,$(LATTICE_BASE_DIR))

    export WINEPATH := "$(LATTICE_BIN_DIR)";"$(LATTICE_TOOLS_DIR)"
    export DYLD_FALLBACK_LIBRARY_PATH=$$DYLD_FALLBACK_LIBRARY_PATH:/usr/lib:"$(LATTICE_WINE_BASE_PATH)/lib64":"$(LATTICE_WINE_BASE_PATH)/lib":"/opt/X11/lib":"/usr/X11/lib"
else
    LATTICE_WINE :=
    LATTICE_NATIVE_BASE_DIR := $(LATTICE_BASE_DIR)

    export PATH := $(LATTICE_BIN_DIR):$(LATTICE_TOOLS_DIR):$$PATH
endif

export LSC_DIAMOND = true
export QT_PLUGIN_PATH =
export NEOCAD_MAXLINEWIDTH = 32767
export FOUNDRY = $(LATTICE_NATIVE_BASE_DIR)/ispfpga
export TCL_LIBRARY = $(LATTICE_NATIVE_BASE_DIR)/tcltk/lib/tcl8.5
export LM_LICENSE_FILE = $(LATTICE_NATIVE_BASE_DIR)/license/license.dat

# Ignored on Windows, but used on Linux and macOS
export LD_LIBRARY_PATH="$$LD_LIBRARY_PATH":"$(LATTICE_BIN_DIR)":"$(LATTICE_TOOLS_DIR)":"$(LATTICE_WINE_BASE_PATH)/lib64":"$(LATTICE_WINE_BASE_PATH)/lib":"/opt/X11/lib":"/usr/X11/lib"
