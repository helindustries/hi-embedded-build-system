FPGA_VENDOR := lattice
FPGA_DEVICE_ID := lfe5u-$(FPGA_DEVICE_SIZE)f
FPGA_CONSTRAINTS ?= $(FPGA_DEVICE).lpf

ifeq ($(strip $(FPGA_DEVICE_ID)), lfe5u-12f)
	FPGA_CHIP_ID := 0x21111043
    FPGA_MASK_FILE := LFE5U-45F.msk
endif
ifeq ($(strip $(FPGA_DEVICE_ID)), lfe5u-25f)
	FPGA_CHIP_ID := 0x41111043
    FPGA_MASK_FILE := LFE5U-45F.msk
endif
ifeq ($(strip $(FPGA_DEVICE_ID)), lfe5u-45f)
	FPGA_CHIP_ID := 0x41113043
    FPGA_MASK_FILE = LFE5U-45F.msk
endif
ifeq ($(strip $(FPGA_DEVICE_ID)), lfe5u-85f)
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
    include $(MAKE_INC_PATH)/Architectures/GHDL/Toolchain.mk
    include $(MAKE_INC_PATH)/Architectures/Yosys/Toolchain.mk
	include $(MAKE_INC_PATH)/Architectures/Yosys/Targets.mk
else
    include $(MAKE_INC_PATH)/Architectures/Lattice/Toolchain.mk
	include $(MAKE_INC_PATH)/Architectures/Lattice/Targets.mk
	include $(MAKE_INC_PATH)/Architectures/Lattice/ModelSimTargets.mk
endif
