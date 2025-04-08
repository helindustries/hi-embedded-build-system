CPPFLAGS += $(INCLUDE_PATHS:%=-I%)
LDFLAGS += $(LIBRARY_PATHS:%=-L%)
LIBS := $(LIBS:%=-l%)
OBJCOPYFLAGS := $(REMOVE_SECTIONS:%=-R .%)

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%$(CPU_BINARY_EXT) $(SOURCES)
	@$(MSG) "[ELF]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(OBJCOPY)" -O ihex $(OBJCOPYFLAGS) "$<" "$@"

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%$(CPU_BINARY_EXT) $(SOURCES)
	@$(MSG) "[BIN]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(OBJCOPY)" -O binary "$<" "$@"

$(BUILD_DIR)/%.eep: $(BUILD_DIR)/%$(CPU_BINARY_EXT)
	@$(MSG) "[EEP]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(OBJCOPY)" -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0 "$<" "$@"

$(BUILD_DIR)/%.lst: $(BUILD_DIR)/%$(CPU_BINARY_EXT)
	@$(MSG) "[LST]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(OBJDUMP)" -d -S -C "$<" > "$@"

$(BUILD_DIR)/%.sym: $(BUILD_DIR)/%$(CPU_BINARY_EXT)
	@$(MSG) "[SYM]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(OBJDUMP)" -t -C "$<" > "$@"

clean_arm:
	@$(MSG) "[CLEAN]" "$(CPU_TARGET)" "ARM $(CPU)"
	$(V)rm -f "$(CPU_TARGET)-$(CPU)$(CPU_BINARY_EXT)" "$(CPU_TARGET)-$(CPU).hex" "$(CPU_TARGET)-$(CPU).eep" "$(CPU_TARGET)-$(CPU).sym" "$(CPU_TARGET)-$(CPU).lst" "$(CPU_TARGET)-$(CPU).post" "$(CPU_TARGET)-$(CPU).zip"

upload_arm: $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).hex $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).eep $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).lst $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).sym

ifeq ($(strip $(FORCE_CPU_UPLOAD)),yes)
ARM_CREATE_TIMESTAMP =
upload_arm_jtag: $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).hex $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).eep $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).lst $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).sym $(SOURCES) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS)
else
ARM_CREATE_TIMESTAMP = && touch "$@"
upload_arm_jtag: $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).hex.upload_arm_jtag.timestamp

%.hex.upload_arm_jtag.timestamp: %.hex %.eep %.lst %.sym $(SOURCES) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS)
endif
ifneq ($(strip $(NO_FIRMWARE_UPLOAD)), yes)
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)set -o pipefail && "$(OPENOCD)" $(OPENOCD_DEBUG) -s "$(OPENOCD_CFG_DIR)" -f "$(OPENOCD_CFG_DIR)/$(CPU_DEBUG_ADAPTER).cfg" -f "$(MAKE_INC_PATH)/Devices/CPU/$(CPU_DEVICE).ocd.cfg" -c "capture 'reset halt; flash write_image erase $(CPU_TARGET)-$(CPU).hex'" -c "shutdown 0" $(PROCESS_OUTPUT) $(ARM_CREATE_TIMESTAMP)
endif

cfg-toolchain:
	@$(MSG) "[CFG]" "$(CPU_TOOLCHAIN)"

.PHONY: clean_arm upload_arm upload_arm_jtag cfg-toolchain
