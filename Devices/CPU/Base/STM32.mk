CORE_PLATFORM := STM32
STM32_BASE_PATH ?= $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/STMicroelectronics/hardware/stm32"/* 2>/dev/null | sort | tail -n 1))
CORE_PATH := $(STM32_BASE_PATH)/cores/arduino
STM32_SYSTEM_PATH := $(STM32_BASE_PATH)/system
CORE_LIB_PATH := $(STM32_BASE_PATH)/libraries
CORE_VARIANTS_PATH := $(STM32_BASE_PATH)/variants/$(STM32_SERIES)
CORE_SKIP_NEW_O := yes

ARM_COMPILERPATH := $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/STMicroelectronics/tools/xpack-arm-none-eabi-gcc"/*/bin 2>/dev/null | sort | tail -n 1))
ARM_CMSIS_PATH ?= $(abspath $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/STMicroelectronics/tools/CMSIS"/*/"CMSIS/DSP/PrivateInclude" 2>/dev/null | sort | tail -n 1))/../..)
ARM_CMSIS_DEVICE_PATH ?= $(STM32_SYSTEM_PATH)/Drivers/CMSIS/Device/ST/$(STM32_SERIES)
ELF_MAP := $(CPU_TARGET).$(CPU_DEVICE).map
STM32_CUBEPROG := bash "$(ARDUINO_USERPATH)/packages/STMicroelectronics/tools/STM32Tools/2.2.1/stm32CubeProg.sh"
STM32_VECTOR_TABLE_OFFSET ?= 0x0
USE_DEFAULT_USB_SERIAL_DETECT := yes

ifeq ($(strip $(STM32_UPLOAD_TYPE)),SWD)
    STM32_UPLOAD_TYPE_ID ?= 0
else
    STM32_UPLOAD_TYPE_ID ?= 2
endif

include $(MAKE_INC_PATH)/Architectures/ARM/Toolchain.mk

CFLAGS += -std=gnu11
CPPFLAGS += -D$(STM32_SERIES) -DARDUINO_STM32_ADAFRUIT -DARDUINO_ARCH_STM32 -DADAFRUIT_FEATHER_STM32 -DVECT_TAB_OFFSET=$(STM32_VECTOR_TABLE_OFFSET)
CPPFLAGS += -fmacro-prefix-map="$(STM32_BASE_PATH)"=. -DSRC_WRAPPER_WITH_LIBSTDCPP
CXXFLAGS += -fno-use-cxa-atexit
ARFLAGS := -rcs
LDFLAGS += -Wl,--no-warn-rwx-segments --specs=nano.specs --specs=nosys.specs
LDFLAGS += -Wl,--defsym=LD_FLASH_OFFSET=$(STM32_VECTOR_TABLE_OFFSET),--defsym=LD_MAX_SIZE=1048576,--defsym=LD_MAX_DATA_SIZE=131072,--entry=Reset_Handler
LDFLAGS += -Wl,--default-script=$(STM32_BASE_PATH)/variants/$(STM32_SERIES)/$(ARDUINO_VARIANT_NAME)/ldscript.ld
ARM_LD := $(STM32_BASE_PATH)/system/ldscript.ld

INCLUDE_PATHS += "$(ARM_CMSIS_DEVICE_PATH)/Include"
INCLUDE_PATHS += "$(ARM_CMSIS_DEVICE_PATH)/Source/Templates/gcc"
INCLUDE_PATHS += "$(ARM_CMSIS_PATH)/Core/Include"
INCLUDE_PATHS += "$(ARM_CMSIS_PATH)/DSP/Include"
INCLUDE_PATHS += "$(ARM_CMSIS_PATH)/DSP/PrivateInclude"
INCLUDE_PATHS += "$(CORE_PATH)/avr"
INCLUDE_PATHS += "$(CORE_PATH)/stm32"
INCLUDE_PATHS += "$(CORE_PATH)/stm32/LL"
INCLUDE_PATHS += "$(CORE_PATH)/stm32/usb"
INCLUDE_PATHS += "$(CORE_PATH)/stm32/OpenAMP"
INCLUDE_PATHS += "$(CORE_PATH)/stm32/usb/hid"
INCLUDE_PATHS += "$(CORE_PATH)/stm32/usb/cdc"
INCLUDE_PATHS += "$(STM32_SYSTEM_PATH)/$(STM32_SERIES)"
INCLUDE_PATHS += "$(STM32_SYSTEM_PATH)/Drivers/$(STM32_SERIES)_HAL_Driver/Inc"
INCLUDE_PATHS += "$(STM32_SYSTEM_PATH)/Drivers/$(STM32_SERIES)_HAL_Driver/Src"
INCLUDE_PATHS += "$(STM32_SYSTEM_PATH)/Middlewares/ST/STM32_USB_Device_Library/Core/Inc"
INCLUDE_PATHS += "$(STM32_SYSTEM_PATH)/Middlewares/ST/STM32_USB_Device_Library/Core/Src"
INCLUDE_PATHS += "$(STM32_SYSTEM_PATH)/Middlewares/OpenAMP"
INCLUDE_PATHS += "$(STM32_SYSTEM_PATH)/Middlewares/OpenAMP/open-amp/lib/include"
INCLUDE_PATHS += "$(STM32_SYSTEM_PATH)/Middlewares/OpenAMP/libmetal/lib/include"
INCLUDE_PATHS += "$(STM32_SYSTEM_PATH)/Middlewares/OpenAMP/virtual_driver"
LIBS += c

include $(MAKE_INC_PATH)/Architectures/ARM/Targets.mk

%.bin.upload_stm32.timestamp: %.bin %.hex serial | silent
ifneq ($(strip $(NO_FIRMWARE_UPLOAD)),yes)
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$<)"

	$(V)$(STM32_CUBEPROG) $(STM32_UPLOAD_TYPE_ID) "$<" $(STM32_VECTOR_TABLE_OFFSET) && echo "$(CPU_DEVICE_PORT)" > "$(BUILD_DIR)/.last_esp32_port" && touch "$@"
	    #$(PROCESS_OUTPUT)
endif

upload_stm32: $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).bin.upload_stm32.timestamp | silent
	@

.PHONY: upload_stm32
