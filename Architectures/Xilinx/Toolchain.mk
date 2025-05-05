FPGA_TOOLCHAIN := xilinx
FPGA_DEPLOY_TARGET := $(FPGA_TARGET).$(FPGA_DEVICE).bit
XILINX_ISE_BUILD_DIR ?= $(BUILD_DIR)/xilinx_ise

# Xilinx tools paths, pointing inside wine prefix
XILINX_ISE_TOOLS_DIR := $(XILINX_ISE_BASE_DIR)/bin/nt64
XILINX_ISE_XST := "$(XILINX_ISE_TOOLS_DIR)/xst.exe"
XILINX_ISE_NGDBUILD := "$(XILINX_ISE_TOOLS_DIR)/ngdbuild.exe"
XILINX_ISE_MAP := "$(XILINX_ISE_TOOLS_DIR)/map.exe"
XILINX_ISE_PAR := "$(XILINX_ISE_TOOLS_DIR)/par.exe"
XILINX_ISE_TRCE := "$(XILINX_ISE_TOOLS_DIR)/trce.exe"
XILINX_ISE_BITGEN := "$(XILINX_ISE_TOOLS_DIR)/bitgen.exe"
XILINX_ISE_FUSE := "$(XILINX_ISE_TOOLS_DIR)/fuse.exe"
XILINX_ISE_ISIMGUI := "$(XILINX_ISE_TOOLS_DIR)/isimgui.exe"

NGDBUILD_ARGS ?=
INTSTYLE := "ise"
FUSE_OPTS := "-intstyle $(INTSTYLE) -incremental -lib secureip"

ifeq ($(strip $(PLATFORM_ID)),macos)
    ifeq ($(strip $(XILINX_ISE_WINE_USE_CROSSOVER)),yes)
        XILINX_ISE_WINE_BASE_PATH ?= /Applications/CrossOver.app/Contents/SharedSupport/CrossOver
        XILINX_ISE_WINE := "$(XILINX_ISE_WINE_BASE_PATH)/bin/wine" --bottle $(call path-basename,"$(XILINX_ISE_WINEPREFIX)")
    else
        XILINX_ISE_WINE_BASE_PATH ?= /Applications/Wine.app/Contents/Resources/wine
        XILINX_ISE_WINE := WINEPREFIX="$(XILINX_ISE_WINEPREFIX)" "$(XILINX_ISE_WINE_BASE_PATH)/bin/wine64"
    endif

    XILINX_ISE_NATIVE_BASE_DIR := $(subst $(LATTICE_WINEPREFIX)/drive_c,c:,$(LATTICE_BASE_DIR))
    export WINEPATH := "$$WINEPATH";"$(LATTICE_BASE_DIR)/common/lib/nt64";"$(LATTICE_BASE_DIR)/ISE/lib/nt64"
    export DYLD_FALLBACK_LIBRARY_PATH="$$DYLD_FALLBACK_LIBRARY_PATH:/usr/lib":"$(XILINX_ISE_WINE_BASE_PATH)/lib64":"$(XILINX_ISE_WINE_BASE_PATH)/lib":"/opt/X11/lib":"/usr/X11/lib"
else
    XILINX_ISE_WINE :=
    XILINX_ISE_NATIVE_BASE_DIR := $(XILINX_ISE_BASE_DIR)
    export PATH := $(XILINX_ISE_TOOLS_DIR):$$PATH
endif

# Ignored on Windows, but used on Linux and macOS
export LD_LIBRARY_PATH="$$LD_LIBRARY_PATH":"$(XILINX_ISE_WINE_BASE_PATH)/lib64":"$(XILINX_ISE_WINE_BASE_PATH)/lib":"/opt/X11/lib":"/usr/X11/lib"
