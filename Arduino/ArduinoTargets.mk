all: binary-mcu stats-mcu | silent
	@:

install: detect-recover binary-mcu upload-mcu | silent
	@:

test: | silent
	@:

clean: clean-mcu | silent
	@:

cfg: cfg-mcu | silent
	@:

wnk: cfg | silent
	@:

# Special board handling defined here, since this is rather Arduino-specific
ifeq ($(strip $(CPU)),nRF52840)
INCLUDE_PATHS += "$(CORE_LIB_PATH)/Adafruit_TinyUSB_Arduino/src/arduino"
MODULES += Adafruit_nRFCrypto:$(CORE_LIB_PATH)/Adafruit_nRFCrypto
MODULES += Adafruit_TinyUSB:$(CORE_LIB_PATH)/Adafruit_TinyUSB_Arduino

# This is required, it solves the problem with symbols for the USB driver not being included in the build otherwise due to the
# Adafruit_TinyUSB library compiled into an archive instead of referencing each object separately like the Arduino build system
LDFLAGS += -Wl,--whole-archive $(BUILD_DIR)/libAdafruit_TinyUSB-$(CPU).a -Wl,--no-whole-archive
endif

ifeq ($(strip $(CPU)),samd21g18a)
MODULES += Adafruit_ZeroDMA:$(CORE_LIB_PATH)/Adafruit_ZeroDMA
endif

# Project target and post-config includes
include $(MAKE_INC_PATH)/Modules.mk
include $(MAKE_INC_PATH)/CPUTargets.mk
include $(MAKE_INC_PATH)/Targets.mk

.PHONY: all install clean test cfg simulate recover detect-recover wnk