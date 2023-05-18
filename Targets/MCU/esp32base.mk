CPUARCH := xtensa
CORE_PLATFORM := ESP32
MCU_DEBUG_ADAPTER ?= esp32-builtin

include $(MAKE_INC_PATH)/Platforms/ESP32/Toolchain.mk
include $(MAKE_INC_PATH)/Platforms/ESP32/Targets.mk
