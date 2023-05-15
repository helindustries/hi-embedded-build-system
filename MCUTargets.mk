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

lib%-$(MCU).a.target:
ifeq ($(strip $(VERBOSE)),1)
	$(V)$(VMSG) "Building Module lib$*-$(MCU).a.target"
	$(V)$(VCFGMSG) "SUBTARGET_NAME:" "$*"
	$(V)$(VCFGMSG) "SUBTARGET_PATH:" "$(MODULES_PATH_$*)"
	$(V)$(VCFGMSG) "MAKE_INC_PATH:" "$(MAKE_INC_PATH)"
	$(V)$(VCFGMSG) "BUILD_DIR:" "$(BUILD_DIR)"
	$(V)$(VCFGMSG) "MCU:" "$(MCU)"
	$(V)$(VCFGMSG) "CC:" "$(CC)"
	$(V)$(VCFGMSG) "CXX:" "$(CXX)"
	$(V)$(VCFGMSG) "AR:" "$(AR)"
endif
	$(V)$(MAKE) --directory="$(MODULES_PATH_$*)" --file "$(MAKE_INC_PATH)/ModulesMakefile.mk" "SUBTARGET_NAME=$*" "SUBTARGET_PATH=$(MODULES_PATH_$*)" "MAKE_INC_PATH=$(MAKE_INC_PATH)" "BUILD_DIR=$(BUILD_DIR)" "MCU=$(MCU)" "CFLAGS=$(CFLAGS)" "CPPFLAGS=$(CPPFLAGS)" "CXXFLAGS=$(CXXFLAGS)" "LDFLAGS=$(LDFLAGS)" "CC=$(CC)" "CXX=$(CXX)" "AR=$(AR)" "V=$(V)" 'MSG=$(MSG)' all

stats-mcu: $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).elf $(SOURCES)
	@echo "ROM: $(shell $(SIZE) -A $< | egrep "\.(text)|(data)" | sed -E 's%\.[a-zA-Z0-9_\.\-]+\ +([0-9]+)\ +[0-9]+%\1%' | awk '{s+=$$1} END {print s}') b, RAM: $(shell $(SIZE) -A $< | egrep "\.((dmabuffers)|(usbbuffers)|(data)|(bss)|(usbdescriptortable))" | sed -E 's%\.[a-zA-Z0-9_\.\-]+\ +([0-9]+)\ +[0-9]+%\1%' | awk '{s+=$$1} END {print s}') b"

upload-mcu: binary-mcu upload_$(MCU_BOARD)$(MCU_JTAG_UPLOAD_TARGET) | silent

clean-mcu: clean-base clean-dependencies clean_${MCU_TOOLCHAIN}
	$(V)rm -f $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).elf	$(BUILD_DIR)/$(MCU_TARGET)-$(MCU)
ifneq ($(strip $(ELF_MAP)),)
	$(V)rm -f $(BUILD_DIR)/$(ELF_MAP)
endif

cfg-mcu:
	$(V)$(MSG) "[CFG]" "$(MCU_TARGET)"
	$(V)$(CFGMSG) "BOARD:" "$(MCU_BOARD)"
	$(V)$(CFGMSG) "PORT:" "$(MCU_BOARD_PORT)"
	$(V)$(CFGMSG) "MCU:" "$(MCU)"
	$(V)$(CFGMSG) "CPU_SPEED:" "$(CPU_SPEED) MHz"
	$(V)$(CFGMSG) "BUS_SPEED:" "$(BUS_SPEED) MHz"
	$(V)$(CFGMSG) "BUILD_DIR:" "$(BUILD_DIR)"
	$(V)$(CFGMSG) "MODULES:" "$(MODULES_NAMES:%=$(strip %))"
	$(V)$(CFGMSG) "MODULES_TARGETS:" "$(MODULES_TARGETS)"
	$(V)$(CFGMSG) "TARGET:" "$(MCU_TARGET)"
	$(V)$(CFGMSG) "CORE_PATH:" "$(CORE_PATH)"
	$(V)$(CFGMSG) "ARDUINO_PATH:" "$(ARDUINO_PATH)"
	$(V)$(CFGMSG) "ARDUINO_USERPATH:" "$(ARDUINO_USERPATH)"
	$(V)$(CFGMSG) "CC:" "$(CC)"
	$(V)$(CFGMSG) "CXX:" "$(CXX)"
	$(V)$(CFGMSG) "AR:" "$(AR)"
	$(V)$(CFGMSG) "OBJCOPY:" "$(OBJCOPY)"
	$(V)$(CFGMSG) "OBJDUMP:" "$(OBJDUMP)"
	$(V)$(CFGMSG) "SIZE:" "$(SIZE)"

.PHONY: serial binary-mcu library-mcu modules-mcu stats-mcu upload-mcu clean-mcu lib%-$(MCU).a.target
