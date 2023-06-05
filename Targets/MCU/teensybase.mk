MCU_BOARD_PORT ?= $(shell "$(abspath $(ARDUINO_PATH)/hardware/tools/teensy_ports)" -L | egrep "\($(SERIAL_ID)\)" | sed -E 's%[a-zA-Z0-9\:]+\ ([a-zA-Z0-9\/\.]+)\ .*%\1%')
MCU_BOARD_RATE ?= 57600
MCU_BOARD_OPTS ?= -DUSB_SERIAL -DLAYOUT_US_ENGLISH

CORE_PLATFORM := Kinetis
CORE_PATH := $(abspath $(ARDUINO_PATH)/hardware/teensy/avr/cores/teensy3)
CORE_LIB_PATH := $(abspath $(ARDUINO_PATH)/hardware/teensy/avr/libraries)
CORE_VARIANTS_PATH :=

ARM_LD := $(CORE_PATH)/$(MCU).ld

include $(MAKE_INC_PATH)/Platforms/ARM/Toolchain.mk
include $(MAKE_INC_PATH)/Platforms/ARM/Targets.mk

%.hex.upload_teensy.timestamp: %.hex upload_arm $(SOURCES) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS) resetter
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)set -o pipefail && $(TEENSY_LOADER) -mmcu=$(LOWER_MCU) -v -w $(MCU_TARGET).hex && touch "$@"

upload_teensy: $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).hex.upload_teensy.timestamp

upload_teensylc: upload_teensy
