# automatically create lists of the sources and objects
SOURCES += $(C_FILES) $(CPP_FILES) $(INO_FILES) $(ASM_FILES) $(HEADERS)
# $(wildcard $(MODULES_PATHS:%,%/*.c) $(MODULES:%,%/*.cpp) $(MODULES:%,%/*.S) $(MODULES:%,%/*.h))
OBJS += $(C_FILES:%.c=$(BUILD_DIR)/%.o) $(CPP_FILES:%.cpp=$(BUILD_DIR)/%.o) $(INO_FILES:%.ino=$(BUILD_DIR)/%.o) $(ASM_FILES:%.s=$(BUILD_DIR)/%.o)

# We allow Makefiles to define CPU_*FLAGS, and either override or include IN_*FLAGS and we pass them around, and we
# then only create the final version of the flags here, not anywere before for clarity
CPU_CFLAGS ?= $(IN_CFLAGS)
CFLAGS := $(CFLAGS) $(CPU_CFLAGS)
CPU_CXXFLAGS ?= $(IN_CXXFLAGS)
CXXFLAGS := $(CXXFLAGS) $(CPU_CXXFLAGS)
CPU_CPPFLAGS ?= $(IN_CPPFLAGS)
CPPFLAGS := $(CPPFLAGS) $(CPU_CPPFLAGS)
CPU_ASMFLAGS ?= $(IN_ASMFLAGS)
ASMFLAGS := $(ASMFLAGS) $(CPU_ASMFLAGS)
CPU_ARFLAGS ?= $(IN_ARFLAGS)
ARFLAGS := $(ARFLAGS) $(CPU_ARFLAGS)
CPU_LDFLAGS ?= $(IN_LDFLAGS)
LDFLAGS := $(LDFLAGS) $(CPU_LDFLAGS)
CPU_OBJCOPYFLAGS ?= $(IN_OBJCOPYFLAGS)
OBJCOPYFLAGS := $(OBJCOPYFLAGS) $(CPU_OBJCOPYFLAGS)

binary-cpu: modules $(CORE_TARGET) $(BUILD_DIR)/$(CPU_TARGET)-$(CPU)$(CPU_BINARY_EXT) $(SOURCES) | silent

library-cpu: modules $(BUILD_DIR)/lib$(CPU_TARGET)-$(CPU).a $(SOURCES) | silent

$(BUILD_DIR)/$(CPU_TARGET)-$(CPU)$(CPU_BINARY_EXT): $(BINARY_DEPS) $(OBJS) $(SOURCES) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS)
	@$(MSG) "[LD]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$@)"
ifeq ($(strip $(ELF_MAP)),)
	$(V)$(CC) $(LDFLAGS) -L$(CORE_LIB_PATH) $(OBJS) $(START_GROUP) $(DEPENDENCY_LIB_PATHS) $(CORE_LIB) $(MODULES_LIBS) $(LIBS) $(END_GROUP) -o "$@"
else
	$(V)$(CC) -Wl,--Map=$(BUILD_DIR)/$(ELF_MAP) $(LDFLAGS) -L$(CORE_LIB_PATH) $(OBJS) $(START_GROUP) $(DEPENDENCY_LIB_PATHS) $(CORE_LIB) $(MODULES_LIBS) $(LIBS) $(END_GROUP) -o "$@"
endif
	$(V)ln -sf $(BUILD_DIR)/$(CPU_TARGET)-$(CPU)$(CPU_BINARY_EXT) $(BUILD_DIR)/$(CPU_TARGET)-$(CPU)

$(BUILD_DIR)/lib$(CPU_TARGET)-$(CPU).a: $(OBJS) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS) $(SOURCES)
	@$(MSG) "[A]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$@)"
	@mkdir -p $(shell dirname "$@")
	$(V)$(AR) $(ARFLAGS) $@ $(OBJS) $(MODULES_LIBS) $(DEPENDENCY_LIB_PATHS)

stats-cpu: $(BUILD_DIR)/$(CPU_TARGET)-$(CPU)$(CPU_BINARY_EXT) $(SOURCES)
	@echo "ROM: $(shell $(SIZE) -A $< | egrep "\.(text)|(data)" | sed -E 's%\.[a-zA-Z0-9_\.\-]+\ +([0-9]+)\ +[0-9]+%\1%' | awk '{s+=$$1} END {print s}') b, RAM: $(shell $(SIZE) -A $< | egrep "\.((dmabuffers)|(usbbuffers)|(data)|(bss)|(usbdescriptortable))" | sed -E 's%\.[a-zA-Z0-9_\.\-]+\ +([0-9]+)\ +[0-9]+%\1%' | awk '{s+=$$1} END {print s}') b"

section-sizes: $(BUILD_DIR)/$(CPU_TARGET)-$(CPU)$(CPU_BINARY_EXT) $(SOURCES)
	$(V)$(SIZE) -A $< > $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).size

symbol-sizes: $(BUILD_DIR)/$(CPU_TARGET)-$(CPU)$(CPU_BINARY_EXT) $(SOURCES)
	$(V)$(OBJDUMP) -t $< | sort -n -k 5 > $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).sym

upload-cpu: binary-cpu upload_$(CPU_DEVICE)$(CPU_JTAG_UPLOAD_TARGET) | silent

clean-cpu: clean-base clean-modules clean_${CPU_TOOLCHAIN}
	@$(MSG) "[CLEAN]" "$(CPU_TARGET)"
	$(V)rm -f $(BUILD_DIR)/$(CPU_TARGET)-$(CPU)$(CPU_BINARY_EXT)	$(BUILD_DIR)/lib$(CPU_TARGET)-$(CPU).a $(BUILD_DIR)/$(CPU_TARGET)-$(CPU)
	$(V)rm -f $(BUILD_DIR)/$(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/*.d
ifneq ($(strip $(ELF_MAP)),)
	$(V)rm -f $(BUILD_DIR)/$(ELF_MAP)
endif

recover:
	@$(MSG) "[RECOVER]" "Perform recovery"
	bash "$(MAKE_INC_PATH)/Tools/FirmwareResetter/recover.sh" full $(CPU_DEVICE) $(CPU_RESET_ARGS) > /dev/null 2>&1

detect-recover:
	@$(MSG) "[RECOVER]" "Check, if recovery is needed"
	@bash "$(MAKE_INC_PATH)/Tools/FirmwareResetter/recover.sh" detect $(CPU_DEVICE) $(CPU_RESET_ARGS) > /dev/null 2>&1

ifneq ($(strip $(HAS_UPLOAD_TARGET)),)
    ifeq ($(strip $(USE_DEFAULT_USB_SERIAL_DETECT)),yes)
        CPU_LAST_PORT_FILE := $(BUILD_DIR)/.last_$(shell echo $(CORE_PLATFORM) | tr '[:lower:]' '[:upper:]')_port
        CPU_DEVICE_PORT ?= $(strip $(shell $(PORTS_BY_IDS) $(strip $(USB_PID)) $(strip $(USB_VID)) $(shell cat "$(CPU_LAST_PORT_FILE)" 2>/dev/null) /dev/cu.usb* | head -n 1))
        ifeq ($(strip $(VERBOSE)),1)
            $(info $(PORTS_BY_IDS) $(strip $(USB_PID)) $(strip $(USB_VID)) $(shell cat "$(CPU_LAST_PORT_FILE)" 2>/dev/null) /dev/cu.usb* | head -n 1)
            $(info Result: $(CPU_DEVICE_PORT))
        endif
        ifeq ($(strip $(CPU_DEVICE_PORT)),)
            CPU_DEVICE_PORT := $(strip $(shell $(PORTS_BY_IDS) $(strip $(USB_PROG_PID)) $(strip $(USB_VID)) $(shell cat "$(CPU_LAST_PORT_FILE)" 2>/dev/null) /dev/cu.usb* | head -n 1))
            ifeq ($(strip $(VERBOSE)),1)
                $(info $(PORTS_BY_IDS) $(strip $(USB_PROG_PID)) $(strip $(USB_VID)) $(shell cat "$(CPU_LAST_PORT_FILE)" 2>/dev/null) /dev/cu.usb* | head -n 1)
                $(info Result: $(CPU_DEVICE_PORT))
            endif
        endif
    endif
endif

serial: | silent
ifneq ($(strip $(NO_FIRMWARE_UPLOAD)),yes)
ifeq ($(strip $(CPU_WAIT_FOR_BOARD_PORT)),yes)
	@$(FMSG) "INFO:Wait for serial on $(CPU_DEVICE_PORT)"
	@$(MSG) "[SERIAL]" "$(CPU_TARGET)" "$(CPU_DEVICE_PORT)"
ifneq ($(strip $(CPU_DEVICE_PORT)),)
	@while [ ! -e "$(CPU_DEVICE_PORT)" ]; do sleep 1; done;
endif
endif

ifeq ($(strip $(CPU_DEVICE_PORT)),)
	@false
endif
endif

cfg-cpu: cfg-toolchain --cfg-cpu
--cfg-cpu:
	@$(MSG) "[CFG]" "$(CPU_TARGET)"
	@$(CFGMSG) "BOARD:" "$(CPU_DEVICE)"
	@$(CFGMSG) "PORT:" "$(CPU_DEVICE_PORT)"
	@$(CFGMSG) "CPU:" "$(CPU)"
	@$(CFGMSG) "CPU_SPEED:" "$(CPU_SPEED) MHz"
	@$(CFGMSG) "BUS_SPEED:" "$(BUS_SPEED) MHz"
	@$(CFGMSG) "BUILD_DIR:" "$(BUILD_DIR)"
	@$(CFGMSG) "MODULES:" "$(MODULES_NAMES:%=$(strip %))"
	@$(CFGMSG) "MODULES_TARGETS:" "$(MODULES_TARGETS)"
	@$(CFGMSG) "TARGET:" "$(CPU_TARGET)"
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

$(BUILD_DIR)/%.o: %.c
	@$(MSG) "[CC]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$<)"
	@mkdir -p $(shell dirname "$@")
	$(V)"$(CC)" -c $(CFLAGS) $(CPPFLAGS) -o "$@" "$<"

$(BUILD_DIR)/%.o: %.cpp
	@$(MSG) "[CXX]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$<)"
	@mkdir -p $(shell dirname "$@")
	$(V)"$(CXX)" -c $(CXXFLAGS) $(CPPFLAGS) -o "$@" "$<"

$(BUILD_DIR)/%.o: %.ino
	@$(MSG) "[INO]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$<)"
	@mkdir -p $(shell dirname "$@")
	$(V)"$(CXX)" -c $(CXXFLAGS) $(CPPFLAGS) -o "$@" -x c++ "$<"

$(BUILD_DIR)/%.o: %.S
	@$(MSG) "[S]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$<)"
	@mkdir -p $(shell dirname "$@")
	$(V)"$(CC)" -c $(ASMFLAGS) $(CPPFLAGS) -o "$@" "$<"

$(BUILD_DIR)/%.o: %.s
	@$(MSG) "[S]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$<)"
	@mkdir -p $(shell dirname "$@")
	$(V)"$(CC)" -c $(ASMFLAGS) $(CPPFLAGS) -o "$@" "$<"

.PHONY: binary-cpu library-cpu stats-cpu upload-cpu clean-cpu cfg-cpu --cfg-cpu lib%-$(CPU).a.target
.NOTPARALLEL: cfg-cpu
