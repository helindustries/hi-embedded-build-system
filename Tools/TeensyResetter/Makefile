all: binary-cpu stats-cpu

install: binary-cpu #upload-cpu

clean: clean-cpu

cfg: cfg-cpu

.PHONY: all install clean

# Set up the base environment
CPU_TARGET = Resetter
CPU_DEVICE = teensy32
override BUILD_DIR = $(abspath Build)
CPU_DEVICE_RATE = 9600
USE_ARDUINO_CORE = yes
USE_ARDUINO_MAIN = yes
CPP_FLAGS = --c++17
CPP_FILES := $(wildcard *.cpp)

include ../../BuildSystem.mk

include $(MAKE_INC_PATH)/CPUFlags.mk
include $(MAKE_INC_PATH)/Modules.mk
include $(MAKE_INC_PATH)/CPUTargets.mk
include $(MAKE_INC_PATH)/Targets.mk
