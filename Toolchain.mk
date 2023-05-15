# Path to your arduino installation
LS := ls --color=never

MAKEFPGAPRJ := "$(MAKE_INC_PATH)/Tools/makefpgaprj.py"
FPGA_FUJPROG ?= $(YOSYS_BIN_PATH)/fujprog
FPGA_DFUUTIL ?= $(YOSYS_BIN_PATH)/dfu-util
FPGA_DFUSUFFIX ?= $(YOSYS_BIN_PATH)/dfu-suffix

IDE ?= sublime
PROCESS_OUTPUT := 2>&1 | python3 "$(MAKE_INC_PATH)/Tools/process_output.py" -f $(IDE)

# Prefer OpenOCD ESP32, as it is compatible with all other platforms as well
OPENOCD ?= $(strip $(shell $(LS) "$(ARDUINO_USERPATH)/packages/esp32/tools/openocd-esp32/*/bin/openocd" 2>/dev/null | sort | tail -n 1))
ifeq ($(strip $(OPENOCD)),)
OPENOCD ?= $(strip $(shell $(LS) "$(ARDUINO_USERPATH)/packages/arduino/tools/openocd/*/bin/openocd" 2>/dev/null | sort | tail -n 1))
endif

OPENOCD_DEBUG := -d0
OPENOCD_CFG_DIR := $(MAKE_INC_PATH)/Tools/OpenOCD
OPENOCD_LOG_PATH ?= $(abspath ./logs/openocd.log)
OPENOCD_GDB_OPTS := -c "gdb_port pipe; log_output $(OPENOCD_LOG_PATH)"
OPENOCD_PORT ?= 3333
OPENOCD_SERVER_OPTS := -c "gdb_port $(OPENOCD_PORT)"

GDB_INIT ?= $(abspath gdbinit)
GDB_TARGET := target extended-remote :$(OPENOCD_PORT)

RESETTER_PORT ?= $(shell "$(abspath $(ARDUINO_PATH)/hardware/tools/teensy_ports)" -L | egrep "\(Teensy\s3.2\)" | sed -E 's%[a-zA-Z0-9\:]+\ ([a-zA-Z0-9\/\.]+)\ .*%\1%')
USE_RESETTER ?= no
