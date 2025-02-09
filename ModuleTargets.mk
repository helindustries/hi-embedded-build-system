$(BUILD_DIR)/$(MODULE_NAME)/%.o: $(MODULE_PATH)/%.c
	@$(MSG) "[CC]" "$(MODULE_NAME)" "$(subst $(abspath $(MODULE_PATH))/,,$<)"
	@mkdir -p $(shell dirname "$@")
	$(V)$(CC) -c $(CFLAGS) $(CPPFLAGS) -o $@ $<

$(BUILD_DIR)/$(MODULE_NAME)/%.o: $(MODULE_PATH)/%.cpp
	@$(MSG) "[CXX]" "$(MODULE_NAME)" "$(subst $(abspath $(MODULE_PATH))/,,$<)"
	@mkdir -p $(shell dirname "$@")
	$(V)$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) -o $@ $<

$(BUILD_DIR)/$(MODULE_NAME)/%.o: $(MODULE_PATH)/%.S
	@$(MSG) "[S]" "$(MODULE_NAME)" "$(subst $(abspath $(MODULE_PATH))/,,$<)"
	@mkdir -p $(shell dirname "$@")
	$(V)$(CC) -c -x assembler-with-cpp  $(CFLAGS) $(CPPFLAGS) -o $@ $<

$(BUILD_DIR)/$(MODULE_NAME)/%.o: $(MODULE_PATH)/%.s
	@$(MSG) "[S]" "$(MODULE_NAME)" "$(subst $(abspath $(MODULE_PATH))/,,$<)"
	@mkdir -p $(shell dirname "$@")
	$(V)$(CC) -c -x assembler-with-cpp  $(CFLAGS) $(CPPFLAGS) -o $@ $<

$(MODULE_LIB): $(MODULE_OBJS) $(MODULE_SOURCES)
	@$(MSG) "[A]" "$(MODULE_NAME)" "$(subst $(abspath .)/,,$@)"
	$(V)$(AR) -rcs $@ $(MODULE_OBJS)

cfg:
	@$(MSG) "[MOD]" "$(MODULE_NAME)"
	@$(CFGMSG) "MODULE_PATH" "$(MODULE_PATH)"
	@$(CFGMSG) "MODULE_LIB" "$(MODULE_LIB)"
	@$(CFGMSG) "MODULE_H_FILES" "$(MODULE_H_FILES)"
	@$(CFGMSG) "MODULE_C_FILES" "$(MODULE_C_FILES)"
	@$(CFGMSG) "MODULE_CPP_FILES" "$(MODULE_CPP_FILES)"
	@$(CFGMSG) "MODULE_ASM_FILES" "$(MODULE_ASM_FILES)"

wnk: cfg | silent
	@:

# compiler generated dependency info
-include $(OBJS:.o=.d)

.PHONE: cfg wnk
