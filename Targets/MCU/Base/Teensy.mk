MCU_BOARD_PORT ?= $(shell "$(abspath $(ARDUINO_PATH)/hardware/tools/teensy_ports)" -L | egrep "\($(SERIAL_ID)\)" | sed -E 's%[a-zA-Z0-9\:]+\ ([a-zA-Z0-9\/\.]+)\ .*%\1%')
MCU_BOARD_RATE ?= 57600
MCU_BOARD_OPTS ?= -DUSB_SERIAL -DLAYOUT_US_ENGLISH

CORE_PLATFORM := Kinetis
CORE_PATH := $(abspath $(ARDUINO_PATH)/hardware/teensy/avr/cores/teensy3)
CORE_LIB_PATH := $(abspath $(ARDUINO_PATH)/hardware/teensy/avr/libraries)
ARM_COMPILERPATH := $(abspath $(ARDUINO_PATH)/hardware/tools/arm/bin)
LIBRARY_PATHS += $(abspath $(ARDUINO_PATH)/hardware/tools/arm/arm-none-eabi/lib)
CORE_VARIANTS_PATH :=
REMOVE_SECTIONS += eeprom
ifneq ($(strip $(WRITE_FULL)),yes)
    REMOVE_SECTIONS += fuse
    REMOVE_SECTIONS += lock
    REMOVE_SECTIONS += signature
endif

ARM_LD := $(CORE_PATH)/$(MCU).ld
CPPFLAGS += -DTEENSYDUINO=151
ARFLAGS := -rcs
USE_DEFAULT_USB_SERIAL_DETECT := no

include $(MAKE_INC_PATH)/Platforms/ARM/Toolchain.mk
include $(MAKE_INC_PATH)/Platforms/ARM/Targets.mk

TEENSY_LOADER=$(MAKE_INC_PATH)/Tools/TeensyLoader/teensy_loader_cli
%.hex.upload_teensy.timestamp: %.hex %.eep %.lst %.sym $(SOURCES) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS) resetter
ifneq ($(strip $(NO_FIRMWARE_UPLOAD)),yes)
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)set -o pipefail && $(TEENSY_LOADER) -mmcu=$(MCU) -v -w $(MCU_TARGET).hex && touch "$@"
endif

upload_teensy: $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).hex.upload_teensy.timestamp

upload_teensylc: upload_teensy
