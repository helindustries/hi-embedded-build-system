FPGA_TOOLCHAIN := xilinx
FPGA_DEPLOY_TARGET := $(FPGA_TARGET).$(FPGA_BOARD).bit
XILINX_BUILD_DIR ?= $(BUILD_DIR)/xilinx

# Xilinx tools paths, pointing inside wine prefix
XILINX_TOOLS_DIR := $(XILINX_BASE_DIR)/bin/nt64
XILINX_XST := "$(XILINX_TOOLS_DIR)/xst.exe"
XILINX_NGDBUILD := "$(XILINX_TOOLS_DIR)/ngdbuild.exe"
XILINX_MAP := "$(XILINX_TOOLS_DIR)/map.exe"
XILINX_PAR := "$(XILINX_TOOLS_DIR)/par.exe"
XILINX_TRCE := "$(XILINX_TOOLS_DIR)/trce.exe"
XILINX_BITGEN := "$(XILINX_TOOLS_DIR)/bitgen.exe"
XILINX_FUSE := "$(XILINX_TOOLS_DIR)/fuse.exe"
XILINX_ISIMGUI := "$(XILINX_TOOLS_DIR)/isimgui.exe"

NGDBUILD_ARGS ?=
INTSTYLE := "ise"
FUSE_OPTS := "-intstyle $(INTSTYLE) -incremental -lib secureip"

ifeq ($(shell uname -s),Darwin)
ifeq ($(strip $(XILINX_WINE_USE_CROSSOVER)),yes)
XILINX_WINE_BASE_PATH ?= /Applications/CrossOver.app/Contents/SharedSupport/CrossOver
XILINX_WINE := "$(XILINX_WINE_BASE_PATH)/bin/wine" --bottle $(shell basename "$(XILINX_WINEPREFIX)")
else
XILINX_WINE_BASE_PATH ?= /Applications/Wine.app/Contents/Resources/wine
XILINX_WINE := WINEPREFIX="$(XILINX_WINEPREFIX)" "$(XILINX_WINE_BASE_PATH)/bin/wine64"
endif

XILINX_NATIVE_BASE_DIR := $(subst $(LATTICE_WINEPREFIX)/drive_c,c:,$(LATTICE_BASE_DIR))
export WINEPATH := "$$WINEPATH";"$(LATTICE_BASE_DIR)/common/lib/nt64";"$(LATTICE_BASE_DIR)/ISE/lib/nt64"
export DYLD_FALLBACK_LIBRARY_PATH="$$DYLD_FALLBACK_LIBRARY_PATH:/usr/lib":"$(XILINX_WINE_BASE_PATH)/lib64":"$(XILINX_WINE_BASE_PATH)/lib":"/opt/X11/lib":"/usr/X11/lib"
else
XILINX_WINE :=
XILINX_NATIVE_BASE_DIR := $(XILINX_BASE_DIR)
export PATH := $(XILINX_TOOLS_DIR):$$PATH
endif

# Ignored on Windows, but used on Linux and macOS
export LD_LIBRARY_PATH="$$LD_LIBRARY_PATH":"$(XILINX_WINE_BASE_PATH)/lib64":"$(XILINX_WINE_BASE_PATH)/lib":"/opt/X11/lib":"/usr/X11/lib"
