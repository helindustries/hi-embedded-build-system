CPUARCH := xtensa
CORE_PLATFORM := ESP32
CPU_DEBUG_ADAPTER ?= esp32-builtin
CPU_RESET_ARGS = "$(ESPTOOL)"
USE_DEFAULT_USB_SERIAL_DETECT := no

include $(MAKE_INC_PATH)/Architectures/ESP32/Toolchain.mk
include $(MAKE_INC_PATH)/Architectures/ESP32/Targets.mk
