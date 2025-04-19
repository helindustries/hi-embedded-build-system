CPU_DEVICE_PORT ?= $(shell "$(abspath $(ARDUINO_PATH)/hardware/tools/teensy_ports)" -L | egrep "\($(SERIAL_ID)\)" | sed -E 's%[a-zA-Z0-9\:]+\ ([a-zA-Z0-9\/\.]+)\ .*%\1%')
CPU_DEVICE_RATE ?= 57600
CPU_CPPFLAGS ?= -DUSB_SERIAL -DLAYOUT_US_ENGLISH

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

ARM_LD := $(CORE_PATH)/$(CPU).ld
CPPFLAGS += -DTEENSYDUINO=151
LDFLAGS += --specs=nano.specs --specs=nosys.specs
ARFLAGS := -rcs
USE_DEFAULT_USB_SERIAL_DETECT := no

include $(MAKE_INC_PATH)/Architectures/ARM/Toolchain.mk
include $(MAKE_INC_PATH)/Architectures/ARM/Targets.mk

TEENSY_LOADER=$(MAKE_INC_PATH)/Tools/TeensyLoader/teensy_loader_cli
%.hex.upload_teensy.timestamp: %.hex %.eep %.lst %.sym $(SOURCES) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS) resetter
ifneq ($(strip $(NO_FIRMWARE_UPLOAD)),yes)
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)set -o pipefail && $(TEENSY_LOADER) -mmcu=$(CPU) -v -w $(CPU_TARGET).hex && touch "$@"
endif

upload_teensy: $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).hex.upload_teensy.timestamp | silent
	@

upload_teensylc: upload_teensy | silent
	@
