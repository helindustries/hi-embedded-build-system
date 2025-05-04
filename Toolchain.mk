# Path to your arduino installation
MAKEFPGAPRJ := "$(MAKE_INC_PATH)/Tools/makefpgaprj.py"
FPGA_FUJPROG ?= $(YOSYS_BIN_PATH)/fujprog
FPGA_DFUUTIL ?= $(YOSYS_BIN_PATH)/dfu-util
FPGA_DFUSUFFIX ?= $(YOSYS_BIN_PATH)/dfu-suffix

IDE ?= sublime
ifeq ($(strip $(NO_PROCESS_OUTPUT)),yes)
	processed_output := $(1)
else
    processed_output := $(shell $(PYTHON) "$(MAKE_INC_PATH)/Tools/process_output.py" -f $(IDE) -c $(1))
endif

# Prefer OpenOCD ESP32, as it is compatible with all other platforms as well
OPENOCD ?= $(call latest,"$(ARDUINO_USERPATH)/packages/esp32/tools/openocd-esp32/*/bin/openocd")
ifeq ($(strip $(OPENOCD)),)
	OPENOCD ?= $(call latest,"$(ARDUINO_USERPATH)/packages/arduino/tools/openocd/*/bin/openocd")
endif

OPENOCD_DEBUG := -d0
OPENOCD_CFG_DIR := $(MAKE_INC_PATH)/Tools/OpenOCD
OPENOCD_LOG_PATH ?= $(abspath ./logs/openocd.log)
OPENOCD_GDB_OPTS := -c "gdb_port pipe; log_output $(OPENOCD_LOG_PATH)"
OPENOCD_PORT ?= 3333
OPENOCD_SERVER_OPTS := -c "gdb_port $(OPENOCD_PORT)"

GDB_INIT ?= $(abspath gdbinit)
GDB_TARGET := target extended-remote :$(OPENOCD_PORT)

PORTS_BY_IDS ?= $(PYTHON) $(abspath $(MAKE_INC_PATH)/Tools/ports_by_ids.py)
RESETTER_PORT ?= $(shell $(MAKE_PLATFORM_UTILS) --exec "$(abspath $(ARDUINO_PATH)/hardware/tools/teensy_ports)" -L \; --filter "\(Teensy 3.2\)" --sub "[a-zA-Z0-9\:]+\ ([a-zA-Z0-9\/\.]+)\ .*" "\1" --print)
USE_RESETTER ?= no
