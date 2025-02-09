CPPFLAGS += $(INCLUDE_PATHS:%=-I%)
LDFLAGS += $(LIBRARY_PATHS:%=-L%)
LIBS := $(LIBS:%=-l%)
OBJCOPYFLAGS := $(REMOVE_SECTIONS:%=-R .%)

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf $(SOURCES)
	@$(MSG) "[ELF]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(OBJCOPY)" -O ihex $(OBJCOPYFLAGS) "$<" "$@"

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf $(SOURCES)
	@$(MSG) "[BIN]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(OBJCOPY)" -O binary "$<" "$@"

$(BUILD_DIR)/%.eep: $(BUILD_DIR)/%.elf
	@$(MSG) "[EEP]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(OBJCOPY)" -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0 "$<" "$@"

$(BUILD_DIR)/%.lst: $(BUILD_DIR)/%.elf
	@$(MSG) "[LST]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(OBJDUMP)" -d -S -C "$<" > "$@"

$(BUILD_DIR)/%.sym: $(BUILD_DIR)/%.elf
	@$(MSG) "[SYM]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(OBJDUMP)" -t -C "$<" > "$@"

clean_arm:
	@$(MSG) "[CLEAN]" "$(MCU_TARGET)" "ARM $(MCU)"
	$(V)rm -f "$(MCU_TARGET)-$(MCU).elf" "$(MCU_TARGET)-$(MCU).hex" "$(MCU_TARGET)-$(MCU).eep" "$(MCU_TARGET)-$(MCU).sym" "$(MCU_TARGET)-$(MCU).lst" "$(MCU_TARGET)-$(MCU).post" "$(MCU_TARGET)-$(MCU).zip"

upload_arm: $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).hex $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).eep $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).lst $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).sym

ifeq ($(strip $(FORCE_MCU_UPLOAD)),yes)
ARM_CREATE_TIMESTAMP =
upload_arm_jtag: $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).hex $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).eep $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).lst $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).sym $(SOURCES) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS)
else
ARM_CREATE_TIMESTAMP = && touch "$@"
upload_arm_jtag: $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).hex.upload_arm_jtag.timestamp

%.hex.upload_arm_jtag.timestamp: %.hex %.eep %.lst %.sym $(SOURCES) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS)
endif
ifneq ($(strip $(NO_FIRMWARE_UPLOAD)), yes)
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)set -o pipefail && "$(OPENOCD)" $(OPENOCD_DEBUG) -s "$(OPENOCD_CFG_DIR)" -f "$(OPENOCD_CFG_DIR)/$(MCU_DEBUG_ADAPTER).cfg" -f "$(MAKE_INC_PATH)/Targets/MCU/$(MCU_BOARD).ocd.cfg" -c "capture 'reset halt; flash write_image erase $(MCU_TARGET)-$(MCU).hex'" -c "shutdown 0" $(PROCESS_OUTPUT) $(ARM_CREATE_TIMESTAMP)
endif

cfg-toolchain:
	@$(MSG) "[CFG]" "$(MCU_TOOLCHAIN)"

.PHONY: clean_arm upload_arm upload_arm_jtag cfg-toolchain
