binary-host: modules $(BUILD_DIR)/$(MCU_TARGET) $(SOURCES) | silent

library-host: modules $(BUILD_DIR)/lib$(MCU_TARGET)-host.a $(SOURCES) | silent

$(BUILD_DIR)/$(MCU_TARGET): $(BINARY_DEPS) $(OBJS) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS) $(SOURCES)
	@$(MSG) "[LD]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(CC)" $(LDFLAGS) $(START_GROUP) $(OBJS) $(MODULES_LIBS) $(LIBS) $(END_GROUP) -o "$@"

$(BUILD_DIR)/lib$(MCU_TARGET).a: $(OBJS) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS) $(SOURCES)
	@$(MSG) "[A]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	@mkdir -p $(shell dirname "$@")
	$(V)"$(AR)" -rcs "$@" $(OBJS) $(MODULES_LIBS)

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

clean-host: clean-base

.PHONY: binary-host library-host clean-host lib%.a.target
