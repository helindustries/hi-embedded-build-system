# automatically create lists of the sources and objects
SOURCES := $(C_FILES) $(CPP_FILES) $(INO_FILES) $(ASM_FILES) $(HEADERS)
# $(wildcard $(MODULES_PATHS:%,%/*.c) $(MODULES:%,%/*.cpp) $(MODULES:%,%/*.S) $(MODULES:%,%/*.h))
OBJS := $(C_FILES:%.c=$(BUILD_DIR)/%.o) $(CPP_FILES:%.cpp=$(BUILD_DIR)/%.o) $(INO_FILES:%.ino=$(BUILD_DIR)/%.o) $(ASM_FILES:%.s=$(BUILD_DIR)/%.o)

binary-mcu: modules $(CORE_TARGET) $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).elf $(SOURCES) | silent

library-mcu: modules $(BUILD_DIR)/lib$(MCU_TARGET)-$(MCU).a $(SOURCES) | silent

$(BUILD_DIR)/$(MCU_TARGET)-$(MCU).elf: $(BINARY_DEPS) $(OBJS) $(SOURCES) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS)
	@$(MSG) "[LD]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
ifeq ($(strip $(ELF_MAP)),)
	$(V)$(CC) $(LDFLAGS) -L$(CORE_LIB_PATH) $(START_GROUP) $(OBJS) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS) $(CORE_LIB) $(LIBS) $(END_GROUP) -Wl,-EL -o "$@"
else
	$(V)$(CC) -Wl,--Map=$(BUILD_DIR)/$(ELF_MAP) $(LDFLAGS) -L$(CORE_LIB_PATH) $(START_GROUP) $(OBJS) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS) $(CORE_LIB) $(LIBS) $(END_GROUP) -o "$@"
endif
	$(V)ln -sf $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).elf $(BUILD_DIR)/$(MCU_TARGET)-$(MCU)

$(BUILD_DIR)/lib$(MCU_TARGET)-$(MCU).a: $(OBJS) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS) $(SOURCES)
	@$(MSG) "[A]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	@mkdir -p $(shell dirname "$@")
	$(V)$(AR) -rcsT $@ $(OBJS) $(MODULES_LIBS) $(DEPENDENCY_LIB_PATHS)

stats-mcu: $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).elf $(SOURCES)
	@echo "ROM: $(shell $(SIZE) -A $< | egrep "\.(text)|(data)" | sed -E 's%\.[a-zA-Z0-9_\.\-]+\ +([0-9]+)\ +[0-9]+%\1%' | awk '{s+=$$1} END {print s}') b, RAM: $(shell $(SIZE) -A $< | egrep "\.((dmabuffers)|(usbbuffers)|(data)|(bss)|(usbdescriptortable))" | sed -E 's%\.[a-zA-Z0-9_\.\-]+\ +([0-9]+)\ +[0-9]+%\1%' | awk '{s+=$$1} END {print s}') b"

upload-mcu: binary-mcu upload_$(MCU_BOARD)$(MCU_JTAG_UPLOAD_TARGET) | silent

clean-mcu: clean-base clean-modules clean_${MCU_TOOLCHAIN}
	$(V)rm -f $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).elf	$(BUILD_DIR)/$(MCU_TARGET)-$(MCU)
ifneq ($(strip $(ELF_MAP)),)
	$(V)rm -f $(BUILD_DIR)/$(ELF_MAP)
endif

cfg-mcu: cfg-toolchain --cfg-mcu
--cfg-mcu:
	@$(MSG) "[CFG]" "$(MCU_TARGET)"
	@$(CFGMSG) "BOARD:" "$(MCU_BOARD)"
	@$(CFGMSG) "PORT:" "$(MCU_BOARD_PORT)"
	@$(CFGMSG) "MCU:" "$(MCU)"
	@$(CFGMSG) "CPU_SPEED:" "$(CPU_SPEED) MHz"
	@$(CFGMSG) "BUS_SPEED:" "$(BUS_SPEED) MHz"
	@$(CFGMSG) "BUILD_DIR:" "$(BUILD_DIR)"
	@$(CFGMSG) "MODULES:" "$(MODULES_NAMES:%=$(strip %))"
	@$(CFGMSG) "MODULES_TARGETS:" "$(MODULES_TARGETS)"
	@$(CFGMSG) "TARGET:" "$(MCU_TARGET)"
	@$(CFGMSG) "CORE_PLATFORM:" "$(CORE_PLATFORM)"
	@$(CFGMSG) "CORE_PATH:" "$(CORE_PATH)"
	@$(CFGMSG) "CORE_LIB_PATH:" "$(CORE_LIB_PATH)"
	@$(CFGMSG) "CORE_VARIANTS_PATH:" "$(CORE_VARIANTS_PATH)"
	@$(CFGMSG) "ARDUINO_PATH:" "$(ARDUINO_PATH)"
	@$(CFGMSG) "ARDUINO_USERPATH:" "$(ARDUINO_USERPATH)"
	@$(CFGMSG) "ARDUINO_VARIANT_NAME:" "$(ARDUINO_VARIANT_NAME)"
	@$(CFGMSG) "CC:" "$(CC)"
	@$(CFGMSG) "CXX:" "$(CXX)"
	@$(CFGMSG) "AR:" "$(AR)"
	@$(CFGMSG) "OBJCOPY:" "$(OBJCOPY)"
	@$(CFGMSG) "OBJDUMP:" "$(OBJDUMP)"
	@$(CFGMSG) "SIZE:" "$(SIZE)"
	@$(CFGMSG) "OPENOCD:" "$(OPENOCD)"

.PHONY: binary-mcu library-mcu stats-mcu upload-mcu clean-mcu cfg-mcu --cfg-mcu lib%-$(MCU).a.target
.NOTPARALLEL: cfg-mcu
