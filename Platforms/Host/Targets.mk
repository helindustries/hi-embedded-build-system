CPPFLAGS += $(INCLUDE_PATHS:%=-I%)
LDFLAGS += $(LIBRARY_PATHS:%=-L%)
LIBS := $(LIBS:%=-l%)

binary-host: modules $(CORE_TARGET) $(BUILD_DIR)/$(MCU_TARGET) $(SOURCES) | silent

library-host: modules $(BUILD_DIR)/lib$(MCU_TARGET)-host.a $(SOURCES) | silent

$(BUILD_DIR)/$(MCU_TARGET): $(BINARY_DEPS) $(OBJS) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS) $(SOURCES)
	@$(MSG) "[LD]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(CC)" $(LDFLAGS) -L$(CORE_LIB_PATH) $(START_GROUP) $(OBJS) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS) $(CORE_LIB) $(LIBS) $(END_GROUP) -o "$@"

$(BUILD_DIR)/lib$(MCU_TARGET).a: $(OBJS) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS) $(SOURCES)
	@$(MSG) "[A]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	@mkdir -p $(shell dirname "$@")
	$(V)"$(AR)" $(ARFLAGS) "$@" $(OBJS) $(MODULES_LIBS) $(DEPENDENCY_LIB_PATHS)

lib%.a.target:
ifeq ($(strip $(VERBOSE)),1)
	@echo "Building Module lib$*.a.target"
	@echo "	SUBTARGET_NAME: $*"
	@echo "	SUBTARGET_PATH: $(MODULES_PATH_$*)"
	@echo "	MAKE_INC_PATH:  $(MAKE_INC_PATH)"
	@echo "	BUILD_DIR:      $(BUILD_DIR)"
	@echo "	MCU:            $(MCU)"
	@echo "	CC:             $(CC)"
	@echo "	CXX:            $(CXX)"
	@echo "	AR:             $(AR)"
endif
	$(V)"$(MAKE)" --directory="$(MODULES_PATH_$*)" --file "$(MAKE_INC_PATH)/Makefile.modules" "SUBTARGET_NAME=$*" "SUBTARGET_PATH=$(MODULES_PATH_$*)" "MAKE_INC_PATH=$(MAKE_INC_PATH)" "BUILD_DIR=$(BUILD_DIR)" "MCU=$(MCU)" "CFLAGS=$(CFLAGS)" "CPPFLAGS=$(CPPFLAGS)" "CXXFLAGS=$(CXXFLAGS)" "LDFLAGS=$(LDFLAGS)" "CC=$(CC)" "CXX=$(CXX)" "AR=$(AR)" "V=$(V)" "MSG=$(MSG)" all

clean_host: clean-base

cfg-host: cfg-toolchain --cfg-host
--cfg-host:
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

cfg-toolchain:
	@$(MSG) "[CFG]" "$(MCU_TOOLCHAIN)"

.PHONY: binary-host library-host clean-host lib%.a.target
