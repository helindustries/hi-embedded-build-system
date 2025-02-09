# 240, 160, 80, 40, 20, 10, 5, 2
CPU_SPEED = 240
# 80, 40, 20, 10, 5, 2
BUS_SPEED = 80

MCU = esp32
CPUARCH = xtensa
SERIAL_ID = "ESP32"
MCU_BOARD_RATE = 921600
MCU_PASSTHROUGH_BIN ?= $(strip $(shell $(LS) "$(ULX3S_PASSTHROUGH_BIN_PATH)/passthru-"*"-$(FPGA_DEVICE_SIZE)f/ulx3s_$(FPGA_DEVICE_SIZE)f_passthru.svf" 2>/dev/null | sort | tail -n 1))
MCU_DEBUG_ADAPTER ?= ulx3s-builtin

include $(MAKE_INC_PATH)/Targets/MCU/Base/ESP32.mk

upload_ulx3s-esp32: upload_esp32

upload_ulx3s-esp32_jtag: upload_esp32_jtag

.PHONY: upload_ulx3s-esp32 upload_ulx3s-esp32_jtag
