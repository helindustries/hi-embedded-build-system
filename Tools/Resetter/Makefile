all: binary-mcu stats-mcu

install: binary-mcu upload-mcu

clean: clean-mcu

cfg: cfg-mcu

.PHONY: all install clean

# Set up the base environment
MCU_TARGET = Resetter
MCU_BOARD = teensy32
override BUILD_DIR = $(abspath Build)
MCU_BOARD_RATE = 9600
USE_ARDUINO_CORE = yes
USE_ARDUINO_MAIN = yes
CPP_FLAGS = --c++17
CPP_FILES := $(wildcard *.cpp)

include ../../BuildSystem.mk

include $(MAKE_INC_PATH)/MCUFlags.mk
include $(MAKE_INC_PATH)/Modules.mk
include $(MAKE_INC_PATH)/MCUTargets.mk
include $(MAKE_INC_PATH)/Targets.mk
