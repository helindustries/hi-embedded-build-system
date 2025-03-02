# automatically create lists of the sources and objects
SOURCES := $(C_FILES) $(CPP_FILES) $(INO_FILES) $(ASM_FILES) $(HEADERS)
# $(wildcard $(MODULES_PATHS:%,%/*.c) $(MODULES:%,%/*.cpp) $(MODULES:%,%/*.S) $(MODULES:%,%/*.h))
OBJS := $(C_FILES:%.c=$(BUILD_DIR)/%.o) $(CPP_FILES:%.cpp=$(BUILD_DIR)/%.o) $(INO_FILES:%.ino=$(BUILD_DIR)/%.o) $(ASM_FILES:%.s=$(BUILD_DIR)/%.o)

binary-mcu: modules $(CORE_TARGET) $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).elf $(SOURCES) | silent

library-mcu: modules $(BUILD_DIR)/lib$(MCU_TARGET)-$(MCU).a $(SOURCES) | silent

$(BUILD_DIR)/$(MCU_TARGET)-$(MCU).elf: $(BINARY_DEPS) $(OBJS) $(SOURCES) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS)
	@$(MSG) "[LD]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
ifeq ($(strip $(ELF_MAP)),)
	$(V)$(CC) $(LDFLAGS) -L$(CORE_LIB_PATH) $(OBJS) $(START_GROUP) $(DEPENDENCY_LIB_PATHS) $(CORE_LIB) $(MODULES_LIBS) $(LIBS) $(END_GROUP) -Wl,-EL -o "$@"
else
	$(V)$(CC) -Wl,--Map=$(BUILD_DIR)/$(ELF_MAP) $(LDFLAGS) -L$(CORE_LIB_PATH) $(OBJS) $(START_GROUP) $(DEPENDENCY_LIB_PATHS) $(CORE_LIB) $(MODULES_LIBS) $(LIBS) $(END_GROUP) -Wl,-EL -o "$@"
endif
	$(V)ln -sf $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).elf $(BUILD_DIR)/$(MCU_TARGET)-$(MCU)

$(BUILD_DIR)/lib$(MCU_TARGET)-$(MCU).a: $(OBJS) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS) $(SOURCES)
	@$(MSG) "[A]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	@mkdir -p $(shell dirname "$@")
	$(V)$(AR) $(ARFLAGS) $@ $(OBJS) $(MODULES_LIBS) $(DEPENDENCY_LIB_PATHS)

stats-mcu: $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).elf $(SOURCES)
	@echo "ROM: $(shell $(SIZE) -A $< | egrep "\.(text)|(data)" | sed -E 's%\.[a-zA-Z0-9_\.\-]+\ +([0-9]+)\ +[0-9]+%\1%' | awk '{s+=$$1} END {print s}') b, RAM: $(shell $(SIZE) -A $< | egrep "\.((dmabuffers)|(usbbuffers)|(data)|(bss)|(usbdescriptortable))" | sed -E 's%\.[a-zA-Z0-9_\.\-]+\ +([0-9]+)\ +[0-9]+%\1%' | awk '{s+=$$1} END {print s}') b"

section-sizes: $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).elf $(SOURCES)
	$(V)$(SIZE) -A $< > $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).size

symbol-sizes: $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).elf $(SOURCES)
	$(V)$(OBJDUMP) -t $< | sort -n -k 5 > $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).sym

upload-mcu: binary-mcu upload_$(MCU_BOARD)$(MCU_JTAG_UPLOAD_TARGET) | silent

clean-mcu: clean-base clean-modules clean_${MCU_TOOLCHAIN}
	@$(MSG) "[CLEAN]" "$(MCU_TARGET)"
	$(V)rm -f $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).elf	$(BUILD_DIR)/lib$(MCU_TARGET)-$(MCU).a $(BUILD_DIR)/$(MCU_TARGET)-$(MCU)
	$(V)rm -f $(BUILD_DIR)/$(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/*.d
ifneq ($(strip $(ELF_MAP)),)
	$(V)rm -f $(BUILD_DIR)/$(ELF_MAP)
endif

recover:
	@$(MSG) "[RECOVER]" "Perform recovery"
	bash "$(MAKE_INC_PATH)/Tools/FirmwareResetter/recover.sh" full $(MCU_BOARD) $(MCU_RESET_ARGS) > /dev/null 2>&1

detect-recover:
	@$(MSG) "[RECOVER]" "Check, if recovery is needed"
	@bash "$(MAKE_INC_PATH)/Tools/FirmwareResetter/recover.sh" detect $(MCU_BOARD) $(MCU_RESET_ARGS) > /dev/null 2>&1

ifeq ($(strip $(USE_DEFAULT_USB_SERIAL_DETECT)),yes)
MCU_LAST_PORT_FILE := $(BUILD_DIR)/.last_$(shell echo $(CORE_PLATFORM) | tr '[:lower:]' '[:upper:]')_port
MCU_BOARD_PORT ?= $(strip $(shell $(PORTS_BY_IDS) $(strip $(USB_PID)) $(strip $(USB_VID)) $(shell cat "$(MCU_LAST_PORT_FILE)" 2>/dev/null) /dev/cu.usb* | head -n 1))
ifeq ($(strip $(VERBOSE)),1)
    $(info $(PORTS_BY_IDS) $(strip $(USB_PID)) $(strip $(USB_VID)) $(shell cat "$(MCU_LAST_PORT_FILE)" 2>/dev/null) /dev/cu.usb* | head -n 1)
    $(info Result: $(MCU_BOARD_PORT))
endif
ifeq ($(strip $(MCU_BOARD_PORT)),)
    MCU_BOARD_PORT := $(strip $(shell $(PORTS_BY_IDS) $(strip $(USB_PROG_PID)) $(strip $(USB_VID)) $(shell cat "$(MCU_LAST_PORT_FILE)" 2>/dev/null) /dev/cu.usb* | head -n 1))
    ifeq ($(strip $(VERBOSE)),1)
        $(info $(PORTS_BY_IDS) $(strip $(USB_PROG_PID)) $(strip $(USB_VID)) $(shell cat "$(MCU_LAST_PORT_FILE)" 2>/dev/null) /dev/cu.usb* | head -n 1)
        $(info Result: $(MCU_BOARD_PORT))
    endif
endif
endif

serial: | silent
ifneq ($(strip $(NO_FIRMWARE_UPLOAD)),yes)
ifeq ($(strip $(MCU_WAIT_FOR_BOARD_PORT)),yes)
	@$(FMSG) "INFO:Wait for serial on $(MCU_BOARD_PORT)"
	@$(MSG) "[SERIAL]" "$(MCU_TARGET)" "$(MCU_BOARD_PORT)"
ifneq ($(strip $(MCU_BOARD_PORT)),)
	@while [ ! -e "$(MCU_BOARD_PORT)" ]; do sleep 1; done;
endif
endif

ifeq ($(strip $(MCU_BOARD_PORT)),)
	@false
endif
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
