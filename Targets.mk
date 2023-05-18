$(BUILD_DIR)/%.o: %.c
	@$(MSG) "[CC]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$<)"
	@mkdir -p $(shell dirname "$@")
	$(V)"$(CC)" -c $(CFLAGS) $(CPPFLAGS) -o "$@" "$<"

$(BUILD_DIR)/%.o: %.cpp
	@$(MSG) "[CXX]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$<)"
	@mkdir -p $(shell dirname "$@")
	$(V)"$(CXX)" -c $(CXXFLAGS) $(CPPFLAGS) -o "$@" "$<"

$(BUILD_DIR)/%.o: %.ino
	@$(MSG) "[INO]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$<)"
	@mkdir -p $(shell dirname "$@")
	$(V)"$(CXX)" -c $(CXXFLAGS) $(CPPFLAGS) -o "$@" -x c++ "$<"

$(BUILD_DIR)/%.o: %.S
	@$(MSG) "[S]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$<)"
	@mkdir -p $(shell dirname "$@")
	$(V)"$(CC)" -c -x assembler-with-cpp  $(CFLAGS) $(CPPFLAGS) -o "$@" "$<"

$(BUILD_DIR)/%.o: %.s
	@$(MSG) "[S]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$<)"
	@mkdir -p $(shell dirname "$@")
	$(V)"$(CC)" -c -x assembler-with-cpp  $(CFLAGS) $(CPPFLAGS) -o "$@" "$<"

clean-base:
	$(V)rm -f $(OBJS) $(OBJS:%.o=%.d)

begin:
	@$(VMSG) "Starting at $(MAKE_BASE_PATH) with '$(MAKECMDGOALS)'"
end:
	@$(VMSG) "Finished at $(MAKE_BASE_PATH) with '$(MAKECMDGOALS)'"

debug_server:
	"$(OPENOCD)" $(OPENOCD_DEBUG) -s "$(OPENOCD_CFG_DIR)" -f "$(OPENOCD_CFG_DIR)/$(MCU_DEBUG_ADAPTER).cfg" -f "$(OPENOCD_CFG_DIR)/$(MCU_DEBUG_TARGET).cfg" $(OPENOCD_SERVER_OPTS)

debug_cli:
	"$(OPENOCD)" $(OPENOCD_DEBUG) -s "$(OPENOCD_CFG_DIR)" -f "$(OPENOCD_CFG_DIR)/$(MCU_DEBUG_ADAPTER).cfg" -f "$(OPENOCD_CFG_DIR)/$(MCU_DEBUG_TARGET).cfg" $(OPENOCD_SERVER_OPTS) -c 'log_output $(OPENOCD_LOG_PATH)' &
	"$(GDB)" --tui -ex '$(GDB_TARGET)' -x '$(GDB_INIT)' '$(BUILD_DIR)/$(MCU_TARGET)-$(MCU).elf'
	killall openocd

serial:
ifneq "$(SERIAL_CONFIG)" ""
	@sleep 10
	open $(abspath $(SERIAL_CONFIG))
endif

resetter:
ifeq ($(strip $(USE_RESETTER)),yes)
	$(V)$(RESETTER_CMD) &
endif

# compiler generated dependency info
-include $(OBJS:.o=.d)

.PHONY: clean-base begin end debug_server debug_cli serial resetter
