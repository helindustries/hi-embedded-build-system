CORE_PLATFORM := SAMD
SAMD_BASE_PATH ?= $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/adafruit/hardware/samd"/* 2>/dev/null | sort | tail -n 1))
CORE_PATH := $(SAMD_BASE_PATH)/cores/arduino
CORE_LIB_PATH := $(SAMD_BASE_PATH)/libraries
CORE_VARIANTS_PATH := $(SAMD_BASE_PATH)/variants
CORE_SKIP_NEW_O := yes

ARM_LD := $(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/linker_scripts/gcc/flash_with_bootloader.ld
ARM_CMSIS_PATH ?= $(abspath $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/adafruit/tools/CMSIS"/*/"CMSIS/DSP/Lib" 2>/dev/null | sort | tail -n 1))/../..)
ARM_CMSIS_DEVICE_PATH ?= $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/adafruit/tools/CMSIS-Atmel"/*/"CMSIS/Device/ATMEL" 2>/dev/null | sort | tail -n 1))
ELF_MAP := $(CPU_TARGET).$(CPU_DEVICE).map
CPPFLAGS += -DARDUINO_SAMD_ADAFRUIT
LDFLAGS += -Wl,--warn-section-align --specs=nano.specs --specs=nosys.specs

USE_DEFAULT_USB_SERIAL_DETECT := no

include $(MAKE_INC_PATH)/Architectures/ARM/Toolchain.mk

INCLUDE_PATHS += "$(ARM_CMSIS_DEVICE_PATH)"
INCLUDE_PATHS += "$(CORE_LIB_PATH)/Adafruit_TinyUSB_Arduino/src/arduino"
INCLUDE_PATHS += "$(ARM_CMSIS_PATH)/Core/Include"
INCLUDE_PATHS += "$(ARM_CMSIS_PATH)/DSP/Include"
LIBRARY_PATHS += "$(ARM_CMSIS_PATH)/DSP/Lib/GCC"
REMOVE_SECTIONS += eeprom
ifneq ($(strip $(WRITE_FULL)),yes)
    REMOVE_SECTIONS += fuse
    REMOVE_SECTIONS += lock
    REMOVE_SECTIONS += signature
endif

include $(MAKE_INC_PATH)/Architectures/ARM/Targets.mk

BOSSAC ?= $(strip $(shell $(LS) "$(ARDUINO_USERPATH)/packages/arduino/tools/bossac"/*/bossac 2>/dev/null | sort | tail -n 1))
CPU_DEVICE_PORT ?= $(strip $(shell for port in $(shell cat "$(BUILD_DIR)/.last_samd_port" 2>/dev/null) "/dev/cu.usb"*; do if $(BOSSAC) --port="$port" -i > /dev/null 2>&1; then echo "$port"; break; fi; done))
%.bin.upload_samd.timestamp: %.bin $(SOURCES) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS) resetter
ifneq ($(strip $(NO_FIRMWARE_UPLOAD)),yes)
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)set -o pipefail && $(BOSSAC) -i -d --port="$(CPU_DEVICE_PORT)" -U -i --offset="$(SAMD_EXEC_OFFSET)" -w -v "$<" -R && echo "$(CPU_DEVICE_PORT)" > "$(BUILD_DIR)/.last_samd_port" && touch "$@"
endif

upload_samd: $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).bin.upload_samd.timestamp
