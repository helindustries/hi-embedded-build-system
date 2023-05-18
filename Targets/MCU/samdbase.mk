CORE_PLATFORM := SAMD
SAMD_BASE_PATH ?= $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/adafruit/hardware/samd"/* 2>/dev/null | sort | tail -n 1))
CORE_PATH := $(SAMD_BASE_PATH)/cores/arduino
CORE_LIB_PATH := $(SAMD_BASE_PATH)/libraries
CORE_VARIANTS_PATH := $(SAMD_BASE_PATH)/variants
CORE_SKIP_NEW_O := yes

ARM_LD := $(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/linker_scripts/gcc/flash_with_bootloader.ld
ELF_MAP := $(MCU_TARGET).$(MCU_BOARD).map

include $(MAKE_INC_PATH)/Platforms/ARM/Toolchain.mk
include $(MAKE_INC_PATH)/Platforms/ARM/Targets.mk

ARM_CMSIS_DEVICE_PATH ?= $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/adafruit/tools/CMSIS-Atmel"/*/"CMSIS/Device/ATMEL" 2>/dev/null | sort | tail -n 1))
CPU_CPPFLAGS += -I$(ARM_CMSIS_DEVICE_PATH) -I$(CORE_LIB_PATH)/Adafruit_TinyUSB_Arduino/src/arduino -I$(ARM_CMSIS_PATH)/Core/Include -I$(ARM_CMSIS_PATH)/DSP/Include
CPU_LDFLAGS += -Wl,--cref -save-temps --specs=nano.specs --specs=nosys.specs -L$(ARM_CMSIS_PATH)/Lib/GCC

BOSSAC ?= $(strip $(shell $(LS) "$(ARDUINO_USERPATH)/packages/arduino/tools/bossac"/*/bossac 2>/dev/null | sort | tail -n 1))
MCU_BOARD_PORT ?= $(strip $(shell for port in $(shell cat "$(BUILD_DIR)/.last_samd_port" 2>/dev/null) "/dev/cu.usb"*; do if $(BOSSAC) --port="$port" -i > /dev/null 2>&1; then echo "$port"; break; fi; done))
%.bin.upload_samd.timestamp: %.bin upload_arm $(SOURCES) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS) resetter
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)set -o pipefail && $(BOSSAC) -i -d --port="$(MCU_BOARD_PORT)" -U -i --offset="$(SAMD_EXEC_OFFSET)" -w -v "$<" -R && echo "$(MCU_BOARD_PORT)" > "$(BUILD_DIR)/.last_samd_port" && touch "$@"

upload_samd: $(MCU_TARGET)-$(MCU).bin.upload_samd.timestamp
