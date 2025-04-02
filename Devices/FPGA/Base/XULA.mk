FPGA_DEVICE_ID_BASE := xula2
FPGA_VENDOR := xilinx

include $(MAKE_INC_PATH)/Architectures/Xilinx/ISEToolchain.mk
include $(MAKE_INC_PATH)/Architectures/Xilinx/ISETargets.mk
include $(MAKE_INC_PATH)/Architectures/Xilinx/ISIMTargets.mk

# Tools
$(FPGA_DEPLOY_TARGET).upload_xula.timestamp: $(FPGA_DEPLOY_TARGET) $(FPGA_RAM_IMAGE) $(FPGA_FLASH_IMAGE) $(FPGA_TARGET_DEPS)
ifneq ($(strip $(NO_GATEWARE_UPLOAD)),yes)
	@if [ -n "$(strip $(FPGA_RAM_IMAGE))" ]; then                     \
		$(FMSG) "INFO:Uploading RAM $(FPGA_RAM_IMAGE)";               \
		$(MSG) "[UPLOAD]" "$(FPGA_TARGET)" "$(FPGA_RAM_IMAGE)"        \
		$(V)"$(XSLOAD)" -b "$(FPGA_DEVICE_ID)" --ram "$(FPGA_RAM_IMAGE)"; \
	fi

	@if [ -n "$(strip $(FPGA_FLASH_IMAGE))" ]; then                       \
		$(FMSG) "INFO:Uploading Flash $(FPGA_FLASH_IMAGE)";               \
		$(MSG) "[UPLOAD]" "$(FPGA_TARGET)" "$(FPGA_FLASH_IMAGE)"          \
		$(V)"$(XSLOAD)" -b "$(FPGA_DEVICE_ID)" --flash "$(FPGA_FLASH_IMAGE)"; \
	fi

	@if [ "$(RUN_LOGIC)" = "yes" ]; then  \
		$(MSG) "[LOGIC]" "$(FPGA_TARGET)" \
		$(V)$(RUN_LOGIC_CMD) &            \
	fi

	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)set -o pipefail && "$(XSLOAD)" -b "$(FPGA_DEVICE_ID)" --fpga "$<" > /dev/null && touch "$@"
endif

upload_xula: $(FPGA_DEPLOY_TARGET).upload_xula.timestamp

.PHONY: upload_xula
