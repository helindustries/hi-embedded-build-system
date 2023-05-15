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

$(MODULE_LIB): $(MODULE_OBJS) $(MODULE_SOURCES)
	@$(MSG) "[A]" "$(MODULE_NAME)" "$(subst $(abspath .)/,,$@)"
	$(V)$(AR) -rcs $@ $(MODULE_OBJS)

cfg:
	@echo "MODULE_NAME:  $(MODULE_NAME)"
	@echo "MODULE_PATH:  $(MODULE_PATH)"
	@echo "BUILD_DIR:    $(BUILD_DIR)/$(MODULE_NAME)"
	@echo "CFLAGS:       $(CFLAGS)"
	@echo "CPPFLAGS:     $(CPPFLAGS)"
	@echo "CXXFLAGS:     $(CXXFLAGS)"
	@echo "LDFLAGS:      $(LDFLAGS)"
	@echo "SOURCES:      $(MODULE_SOURCES)"
	@echo "MODULE_LIB:   $(MODULE_LIB)"

# compiler generated dependency info
-include $(OBJS:.o=.d)
