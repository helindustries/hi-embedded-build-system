FPGA_DEVICE ?= xula2-lx25
FPGA_TARGET ?= $(basename $(realpath $(abspath .)))
FPGA_RAM_IMAGE ?=
FPGA_FLASH_IMAGE ?=
FPGA_ROMS ?=
FPGA_PROJECT_ARGS ?=

FPGA_USE_JTAG ?=
FPGA_JTAG_UPLOAD_TARGET :=
FPGA_DEBUG_TARGET := $(FPGA_DEVICE)
ifeq ($(strip $(FPGA_USE_JTAG)),yes)
	FPGA_JTAG_UPLOAD_TARGET := _jtag
endif

include $(MAKE_INC_PATH)/Devices/FPGA/$(FPGA_DEVICE).mk

FPGA_PROJECT_ARGS ?=
FPGA_PROJECT_ARGS += -s $(FPGA_BASE_LIBRARY_PATH)/boards/$(FPGA_DEVICE_BASE).vhd
FPGA_PROJECT_ARGS += -i helindustries_platform:$(FPGA_BASE_LIBRARY_PATH)/platform/$(FPGA_VENDOR)
FPGA_PROJECT_ARGS += -i helindustries:$(FPGA_BASE_LIBRARY_PATH)

FPGA_TARGET_DEPS := $(shell $(MAKEFPGAPRJ) "$(FPGA_TARGET).vhd" -a -l "work" -p $(FPGA_PROJECT_ARGS))
FPGA_TARGET_DEPS += $(shell $(MAKE_PLATFORM_UTILS) $(FPGA_ROMS:%=--in "%") --sub "_rom.txt" "_rom_base.txt" --sub "_ram.txt" "_ram_base.txt" --sub "_tb.txt" "_tb_base.txt" --print)
FPGA_TARGET_DEPS += $(shell $(MAKE_PLATFORM_UTILS) $(FPGA_ROMS:%=--in "%") --sub "_rom.txt" "_rom_gen.py" --sub "_ram.txt" "_ram_gen.py" --sub "_tb.txt" "_tb_gen.py" --print)
