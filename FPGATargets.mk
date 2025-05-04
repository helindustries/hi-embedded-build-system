roms: $(FPGA_ROMS) | silent

synthesize: synthesize_${FPGA_TOOLCHAIN} $(FPGA_TARGET_DEPS) | silent

layout: layout_${FPGA_TOOLCHAIN} $(FPGA_TARGET_DEPS) | silent

upload-fpga: upload_$(FPGA_DEVICE)$(FPGA_JTAG_UPLOAD_TARGET) $(FPGA_TARGET_DEPS) | silent

clean-fpga: clean_${FPGA_TOOLCHAIN}
	@$(MSG) "[CLEAN]" "$(FPGA_TARGET)"
ifneq ($(strip $(FPGA_ROMS)),)
	$(V)$(RM) "$(FPGA_ROMS)"
endif
	$(V)$(RM) "$(FPGA_TARGET).prj"

%_rom.txt: %_rom_gen.py %_rom_base.txt
	@$(MSG) "[ROM]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)python $< $*_rom_base.txt $@

%_rom.txt: %_rom_gen.sh %_rom_base.txt
	@$(MSG) "[ROM]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)bash $< $*_rom_base.txt $@

%_ram.txt: %_ram_gen.py %_ram_base.txt
	@$(MSG) "[RAM]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)python $< $*_ram_base.txt $@

%_ram.txt: %_ram_gen.sh %_ram_base.txt
	@$(MSG) "[RAM]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)bash $< $*_ram_base.txt $@

%_tb.txt: %_tb_gen.py %_tb_base.txt
	@$(MSG) "[ROM]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)python $< $*_tb_base.txt $@

%_tb.txt: %_tb_gen.sh %_tb_base.txt
	@$(MSG) "[ROM]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)bash $< $*_tb_base.txt $@

%.bit.dfu: %.bit
	@$(MSG) "[BIT]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)cp "$<" "$@"
	$(V)$(FPGA_DFUSUFFIX) -v $(FPGA_VENDOR_ID) -p $(FPGA_PRODUCT_ID) -a "$@"

#FPGA_FUJPROG ?= $(TOOLCHAIN_PATH)/FPGA/bin/fujprog
$(FPGA_DEPLOY_TARGET).upload_fujprog.timestamp: $(FPGA_DEPLOY_TARGET) $(FPGA_TARGET_DEPS)
ifneq ($(strip $(NO_GATEWARE_UPLOAD)),yes)
	@# TODO: Find or develop FPGA too to upload ram and flash images
	@#@if [ -n "$(strip $(FPGA_RAM_IMAGE))" ]; then              \
	@#	$(FMSG) "INFO:Uploading RAM $(FPGA_RAM_IMAGE)";          \
	@#	$(MSG) "[UPLOAD]" "$(FPGA_TARGET)" "$(FPGA_RAM_IMAGE)"   \
	@#	$(FPGA_FUJPROG) -b "$(FPGA_DEVICE)" --ram "$(FPGA_RAM_IMAGE)"; \
	@#fi

	@#@if [ -n "$(strip $(FPGA_FLASH_IMAGE))" ]; then                \
	@#	$(FMSG) "INFO:Uploading Flash $(FPGA_FLASH_IMAGE)";          \
	@#	$(MSG) "[UPLOAD]" "$(FPGA_TARGET)" "$(FPGA_FLASH_IMAGE)"     \
	@#	$(FPGA_FUJPROG) -b "$(FPGA_DEVICE)" --flash "$(FPGA_FLASH_IMAGE)"; \
	@#fi

	@if [ "$(RUN_LOGIC)" = "yes" ]; then  \
		$(MSG) "[LOGIC]" "$(FPGA_TARGET)" \
		$(V)$(RUN_LOGIC_CMD) &            \
	fi

	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)$(MAKE_PLATFORM_UTILS) --exec $(FPGA_FUJPROG) "$<" \; && $(TOUCH) "$@"
endif

upload_fujprog: $(FPGA_DEPLOY_TARGET).upload_fujprog.timestamp

$(FPGA_DEPLOY_TARGET).upload_dfuutil.timestamp: $(FPGA_DEPLOY_TARGET) $(FPGA_TARGET_DEPS)
ifneq ($(strip $(NO_GATEWARE_UPLOAD)),yes)
	@# TODO: Find or develop FPGA too to upload ram and flash images
	@#@if [ -n "$(strip $(FPGA_RAM_IMAGE))" ]; then              \
	@#	$(FMSG) "INFO:Uploading RAM $(FPGA_RAM_IMAGE)";          \
	@#	$(MSG) "[UPLOAD]" "$(FPGA_TARGET)" "$(FPGA_RAM_IMAGE)"   \
	@#	$(FPGA_FUJPROG) -b "$(FPGA_DEVICE)" --ram "$(FPGA_RAM_IMAGE)"; \
	@#fi

	@#@if [ -n "$(strip $(FPGA_FLASH_IMAGE))" ]; then                \
	@#	$(FMSG) "INFO:Uploading Flash $(FPGA_FLASH_IMAGE)";          \
	@#	$(MSG) "[UPLOAD]" "$(FPGA_TARGET)" "$(FPGA_FLASH_IMAGE)"     \
	@#	$(FPGA_FUJPROG) -b "$(FPGA_DEVICE)" --flash "$(FPGA_FLASH_IMAGE)"; \
	@#fi

	@if [ "$(RUN_LOGIC)" = "yes" ]; then  \
		$(MSG) "[LOGIC]" "$(FPGA_TARGET)" \
		$(V)$(RUN_LOGIC_CMD) &            \
	fi

	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)$(MAKE_PLATFORM_UTILS) --exec $(FPGA_DFUUTIL) -a 0 -D "$<" \; && $(TOUCH) "$@"
endif

upload_dfuutil: $(FPGA_DEPLOY_TARGET).upload_dfuutil.timestamp

cfg-fpga:
	@echo "BOARD:                  $(FPGA_DEVICE)"
	@echo "BUILD_DIR:              $(BUILD_DIR)"
	@echo "TARGET:                 $(FPGA_TARGET)"
	@echo "FPGA_BASE_LIBRARY_PATH: $(FPGA_BASE_LIBRARY_PATH)"

.PHONY: roms synthesize layout upload-fpga clean-fpga upload_xilinx_jtag upload_fujprog upload_dfuutil cfg-fpga