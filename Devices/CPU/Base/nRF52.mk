CORE_PLATFORM := NRF52
NRF52_BASE_PATH ?= $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/adafruit/hardware/nrf52"/* 2>/dev/null | sort | tail -n 1))
CORE_PATH := $(NRF52_BASE_PATH)/cores/nRF5
CORE_LIB_PATH := $(NRF52_BASE_PATH)/libraries
CORE_VARIANTS_PATH := $(NRF52_BASE_PATH)/variants
CORE_SKIP_NEW_O := yes

ARM_CMSIS_PATH ?= $(abspath $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/adafruit/tools/CMSIS"/*/"CMSIS/DSP/Lib" 2>/dev/null | sort | tail -n 1))/../..)
ARM_CMSIS_DEVICE_PATH ?= $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/adafruit/tools/CMSIS"/*/"CMSIS/Device/ARM" 2>/dev/null | sort | tail -n 1))
ELF_MAP := $(CPU_TARGET).$(CPU_DEVICE).map
NRFUTIL ?= $(NRF52_BASE_PATH)/tools/adafruit-nrfutil/macos/adafruit-nrfutil
CPU_RESET_ARGS = $(USB_PID) $(USB_VID) "$(NRFUTIL)"
USE_DEFAULT_USB_SERIAL_DETECT := yes

include $(MAKE_INC_PATH)/Architectures/ARM/Toolchain.mk

CFLAGS += -std=gnu11
CPPFLAGS += -DARDUINO_NRF52_ADAFRUIT -DARDUINO_ARCH_NRF52 -DNRF52_SERIES -DADAFRUIT_FEATHER_NRF52 "-DARDUINO_BSP_VERSION=\"1.6.1\""
CPPFLAGS += -DSOFTDEVICE_PRESENT -DDX_CC_TEE -DLFS_NAME_MAX=64 -DCFG_DEBUG=0 -DCFG_LOGGER=0 -DCFG_SYSVIEW=0 -u _printf_float
ARFLAGS := -rcs
LDFLAGS += -Wl,--warn-section-align -Wl,--wrap=malloc,--wrap=free,--wrap=realloc,--wrap=calloc -u _printf_float

INCLUDE_PATHS += "$(ARM_CMSIS_DEVICE_PATH)"
INCLUDE_PATHS += "$(CORE_LIB_PATH)/Adafruit_TinyUSB_Arduino/src/arduino"
INCLUDE_PATHS += "$(ARM_CMSIS_PATH)/Core/Include"
INCLUDE_PATHS += "$(ARM_CMSIS_PATH)/DSP/Include"
INCLUDE_PATHS += "$(CORE_PATH)/nordic"
INCLUDE_PATHS += "$(CORE_PATH)/nordic/nrfx"
INCLUDE_PATHS += "$(CORE_PATH)/nordic/nrfx/hal"
INCLUDE_PATHS += "$(CORE_PATH)/nordic/nrfx/mdk"
INCLUDE_PATHS += "$(CORE_PATH)/nordic/nrfx/soc"
INCLUDE_PATHS += "$(CORE_PATH)/nordic/nrfx/drivers/include"
INCLUDE_PATHS += "$(CORE_PATH)/nordic/nrfx/drivers/src"
INCLUDE_PATHS += "$(CORE_PATH)/nordic/softdevice/s140_nrf52_6.1.1_API/include"
INCLUDE_PATHS += "$(CORE_PATH)/nordic/softdevice/s140_nrf52_6.1.1_API/include/nrf52"
INCLUDE_PATHS += "$(CORE_PATH)/freertos/Source/include"
INCLUDE_PATHS += "$(CORE_PATH)/freertos/config"
INCLUDE_PATHS += "$(CORE_PATH)/freertos/portable/GCC/nrf52"
INCLUDE_PATHS += "$(CORE_PATH)/freertos/portable/CMSIS/nrf52"
INCLUDE_PATHS += "$(CORE_PATH)/sysview/SEGGER"
INCLUDE_PATHS += "$(CORE_PATH)/sysview/Config"
LIBRARY_PATHS += "$(ARM_CMSIS_PATH)/DSP/Lib/GCC"
LIBRARY_PATHS += "$(CORE_PATH)/linker"
LIBRARY_PATHS += "$(CORE_LIB_PATH)/Adafruit_nRFCrypto/src/cortex-m4/fpv4-sp-d16-hard"
LIBS += nrf_cc310_0.9.13-no-interrupts

include $(MAKE_INC_PATH)/Architectures/ARM/Targets.mk

%.zip: %.hex %.eep %.lst %.sym $(SOURCES) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS) resetter
	@$(MSG) "[ZIP]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)$(NRFUTIL) dfu genpkg --dev-type $(NRF52_DEV_TYPE) --sd-req $(NRF52_SD_SEQ) --application "$<" "$@" > /dev/null

%.zip.upload_nrf52.timestamp: %.zip serial | silent
ifneq ($(strip $(NO_FIRMWARE_UPLOAD)),yes)
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$<)"

	$(V)$(NRFUTIL) dfu serial -pkg "$<" -p $(CPU_DEVICE_PORT) -b 115200 --singlebank $(NRF52_TOUCH_ARG) \
	    && echo "$(CPU_DEVICE_PORT)" > "$(BUILD_DIR)/.last_esp32_port" && touch "$@"
	    #$(PROCESS_OUTPUT)
endif

upload_nrf52: $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).zip.upload_nrf52.timestamp | silent
	@

.PRECIOUS: %.zip
.PHONY: upload_nrf52