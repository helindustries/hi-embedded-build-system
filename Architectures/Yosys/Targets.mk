YOSYS_BUILD_DIR ?= $(BUILD_DIR)/yosys
YOSYS_WORK ?= work
YOSYS_GHDL_ARGS ?= --std=93 --ieee=synopsys -fexplicit -Wno-pure
YOSYS_LIB_ARGS := $(shell $(MAKE_PLATFORM_UTILS) --exec $(MAKEFPGAPRJ) "$(FPGA_TARGET).vhd" --ghdl -l "$(YOSYS_WORK)" $(FPGA_PROJECT_ARGS) \; --sub "([a-zA-Z0-9_\-]+)\ .*" "-P$(YOSYS_BUILD_DIR)/\1/%" --filter-out "^-P$(YOSYS_BUILD_DIR)\/work" --sort asc --unique --print)
YOSYS_LIB_DEPS=$(shell $(MAKE_PLATFORM_UTILS) --exec $(MAKEFPGAPRJ) "$(FPGA_TARGET).vhd" --ghdl -l "$(YOSYS_WORK)" $(FPGA_PROJECT_ARGS) \; --sub "([a-zA-Z0-9_\-]+)\ .*" "$(YOSYS_BUILD_DIR)/\1/\1-obj93.cf" --sort asc --unique --print)
YOSYS_TARGET_FILES = $(shell $(MAKE_PLATFORM_UTILS) --exec $(MAKEFPGAPRJ) "$(FPGA_TARGET).vhd" --yosys -l "$(YOSYS_WORK)" $(FPGA_PROJECT_ARGS) \; --sub "([a-zA-Z0-9_\-]+)\ (.*\/)?([a-zA-Z0-9_\-\.]+\.v)(hd(l)?)?$$" "$(YOSYS_BUILD_DIR)/\1/\3" --sort asc --unique --print)
#YOSGS_GHDL_PLUGIN ?= -m ghdl
YOSYS_LIB_ARGS +=  -P$(GHDL_LATTICE_LIB)

%.ysproj: %.vhd $(FPGA_ROMS)
	@$(MSG) "[YSPROJ]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)$(MAKE_PLATFORM_UTILS) --exec $(MAKEFPGAPRJ) "$<" --ghdl -l "$(YOSYS_WORK)" $(FPGA_PROJECT_ARGS) \; --foreach $(GHDL_ANALZYE) $(GHDL) $(YOSYS_BUILD_DIR) $(YOSYS_GHDL_ARGS) $(YOSYS_LIB_ARGS) \;
	$(V)"$(GHDL)" -a $(YOSYS_GHDL_ARGS) $(YOSYS_LIB_ARGS) --work=$(YOSYS_WORK) --workdir=$(YOSYS_BUILD_DIR)/$(YOSYS_WORK) "$<"
	$(V)"$(YOSYS)" $(YOSYS_GHDL_PLUGIN) -p "ghdl $(YOSYS_GHDL_ARGS) $(YOSYS_LIB_ARGS) --work=$(YOSYS_WORK) --workdir=$(YOSYS_BUILD_DIR)/$(YOSYS_WORK) $*; $(YOSYS_COMMAND) ${YOSYS_OPTS} -json $@"

%.config: %.ysproj %.$(FPGA_CONSTRAINTS)
	@$(MSG) "[CONFIG]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(NEXTPNR)" $(NEXTPNR_OPTS) --$(FPGA_DEVICE_SIZE)k --package $(FPGA_PACKAGE) --json "$<" --lpf "$*.$(FPGA_CONSTRAINTS)" --textcfg "$@"

%.$(FPGA_DEVICE).bit: %.config
	@$(MSG) "[BIT]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(ECPPACK)" $(ECPPACK_OPTS) --compress --freq "$(FPGA_FLASH_READ_MHZ)" --input "$<" --bit "$@"

synthesize_yosys: layout_yosys

layout_yosys: $(FPGA_TARGET).ysproj

clean_yosys:
	@$(MSG) "[CLEAN]" "$(FPGA_TARGET)" "Yosys"
ifneq ($(strip $(YOSYS_BUILD_DIR)),)
	$(V)$(RMDIR) "$(YOSYS_BUILD_DIR)"
endif
	$(V)$(RM) "$(FPGA_TARGET).ysproj" "$(FPGA_TARGET).config"

.PHONY: synthesize_yosys layout_yosys clean_yosys
