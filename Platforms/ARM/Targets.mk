CPPFLAGS += -I. $(MODULES_PATHS:%=-I%) $(DEPENDENCY_PATHS:%=-I%) -I$(CORE_PATH)

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf $(BUILD_DIR)/%.eep $(SOURCES)
	@$(MSG) "[ELF]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
ifeq ($(strip $(WRITE_FULL)), yes)
	$(V)"$(OBJCOPY)" -O ihex -R .eeprom -R .fuse -R .lock -R .signature "$<" "$@"
else
	$(V)"$(OBJCOPY)" -O ihex -R .eeprom "$<" "$@"
endif

$(BUILD_DIR)/%.eep: $(BUILD_DIR)/%.elf
	@$(MSG) "[EEP]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(OBJCOPY)" -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0 "$<" "$@"

$(BUILD_DIR)/%.lst: $(BUILD_DIR)/%.elf $(BUILD_DIR)/%.hex
	@$(MSG) "[LST]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(OBJDUMP)" -d -S -C "$<" > "$@"

$(BUILD_DIR)/%.sym: $(BUILD_DIR)/%.elf $(BUILD_DIR)/%.lst
	@$(MSG) "[SYM]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(OBJDUMP)" -t -C "$<" > "$@"

clean_arm:
	rm -f "$(MCU_TARGET)-$(MCU).elf" "$(MCU_TARGET)-$(MCU).hex" "$(MCU_TARGET)-$(MCU).eep" "$(MCU_TARGET)-$(MCU).sym" "$(MCU_TARGET)-$(MCU).lst" "$(MCU_TARGET)-$(MCU).post"

upload_arm: $(MCU_TARGET)-$(MCU).eep $(MCU_TARGET)-$(MCU).hex $(MCU_TARGET)-$(MCU).lst $(MCU_TARGET)-$(MCU).sym

%.hex.upload_arm_jtag.timestamp: %.hex %.eep %.lst %.sym $(SOURCES) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS)
ifneq ($(strip $(MCU_JTAG_UPLOAD_BY_IDE)), yes)
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)set -o pipefail && "$(OPENOCD)" $(OPENOCD_DEBUG) -s "$(OPENOCD_CFG_DIR)" -f "$(OPENOCD_CFG_DIR)/$(MCU_DEBUG_ADAPTER).cfg" -f "$(MAKE_INC_PATH)/Targets/MCU/$(MCU_BOARD).ocd.cfg" -c "capture 'reset halt; flash write_image erase $(MCU_TARGET)-$(MCU).hex'" -c "shutdown 0" $(PROCESS_OUTPUT) && touch "$@"
endif

upload_arm_jtag: $(MCU_TARGET)-$(MCU).hex.upload_arm_jtag.timestamp
