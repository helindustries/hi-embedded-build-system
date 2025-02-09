FPGA_VENDOR := lattice
FPGA_DEVICE := lfe5u-$(FPGA_DEVICE_SIZE)f
FPGA_CONSTRAINTS ?= $(FPGA_BOARD).lpf

ifeq ($(strip $(FPGA_DEVICE)), lfe5u-12f)
	FPGA_CHIP_ID := 0x21111043
    FPGA_MASK_FILE := LFE5U-45F.msk
endif
ifeq ($(strip $(FPGA_DEVICE)), lfe5u-25f)
	FPGA_CHIP_ID := 0x41111043
    FPGA_MASK_FILE := LFE5U-45F.msk
endif
ifeq ($(strip $(FPGA_DEVICE)), lfe5u-45f)
	FPGA_CHIP_ID := 0x41113043
    FPGA_MASK_FILE = LFE5U-45F.msk
endif
ifeq ($(strip $(FPGA_DEVICE)), lfe5u-85f)
	FPGA_CHIP_ID := 0x41113043
    FPGA_MASK_FILE := LFE5U-85F.msk
endif

ifeq ($(strip $(FPGA_TOOLCHAIN)), yosys)
	FPGA_PROJECT_ARGS += -i ecp5u:$(YOSYS_GHDL_PLUGIN)/library/ecp5u
endif

YOSYS_TYPE := ecp5
NEXTPNR_OPTS := --um5g-85k

# Enable switching between Diamond and Yosys
ifeq ($(strip $(FPGA_TOOLCHAIN)),yosys)
    include $(MAKE_INC_PATH)/Platforms/GHDL/Toolchain.mk
    include $(MAKE_INC_PATH)/Platforms/Yosys/Toolchain.mk
	include $(MAKE_INC_PATH)/Platforms/Yosys/Targets.mk
else
    include $(MAKE_INC_PATH)/Platforms/Lattice/Toolchain.mk
	include $(MAKE_INC_PATH)/Platforms/Lattice/Targets.mk
	include $(MAKE_INC_PATH)/Platforms/Lattice/ModelSimTargets.mk
endif
