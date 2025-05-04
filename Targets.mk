clean-base:
	$(V)$(RM) $(OBJS) $(OBJS:%.o=%.d)

begin:
	@$(VMSG) "Starting at $(MAKE_BASE_PATH) with '$(MAKECMDGOALS)'"
end:
	@$(VMSG) "Finished at $(MAKE_BASE_PATH) with '$(MAKECMDGOALS)'"

debug_server:
	"$(OPENOCD)" $(OPENOCD_DEBUG) -s "$(OPENOCD_CFG_DIR)" -f "$(OPENOCD_CFG_DIR)/$(CPU_DEBUG_ADAPTER).cfg" -f "$(OPENOCD_CFG_DIR)/$(CPU_DEBUG_TARGET).cfg" $(OPENOCD_SERVER_OPTS)

debug_cli:
	"$(OPENOCD)" $(OPENOCD_DEBUG) -s "$(OPENOCD_CFG_DIR)" -f "$(OPENOCD_CFG_DIR)/$(CPU_DEBUG_ADAPTER).cfg" -f "$(OPENOCD_CFG_DIR)/$(CPU_DEBUG_TARGET).cfg" $(OPENOCD_SERVER_OPTS) -c 'log_output $(OPENOCD_LOG_PATH)' &
	"$(GDB)" --tui -ex '$(GDB_TARGET)' -x '$(GDB_INIT)' '$(BUILD_DIR)/$(CPU_TARGET)-$(CPU)$(CPU_BINARY_EXT)'
	killall openocd

serial:
ifneq "$(SERIAL_CONFIG)" ""
	@sleep 10
	$(V)$(PLATFORM_OPEN_FILE) $(abspath $(SERIAL_CONFIG))
endif

resetter:
ifeq ($(strip $(USE_RESETTER)),yes)
	$(V)$(RESETTER_CMD) &
endif

# compiler generated dependency info
-include $(OBJS:.o=.d)

.PHONY: clean-base begin end debug_server debug_cli serial resetter
