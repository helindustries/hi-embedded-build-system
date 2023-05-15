all: binary-mcu stats-mcu

install: binary-mcu upload-mcu

clean: clean-mcu

.PHONY: all install clean

# Set up the base environment
MCU_TARGET = Resetter
MCU_BOARD = teensy32
MCU_BOARD_RATE = 9600
BUILD_DIR = $(abspath $(MAKE_BASE_PATH)/Build/$(MCU_TARGET))
USE_ARDUINO_CORE = yes
USE_ARDUINO_MAIN = yes
CPP_FLAGS = --c++17
CPP_FILES := $(wildcard *.cpp)

# Put any additional boards here
ifeq ($(strip $(MCU_BOARD)),teensy32)
endif
ifeq ($(strip $(MCU_BOARD)),teensy36)
endif

include ../../BuildSystem.mk
include $(MAKE_INC_PATH)/MCUFlags.mk
include $(MAKE_INC_PATH)/MCUTargets.mk
include $(MAKE_INC_PATH)/Targets.mk
