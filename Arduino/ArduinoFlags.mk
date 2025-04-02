USE_ARDUINO_MAIN = yes
USE_ARDUINO_CORE = yes
BUILD_DIR ?= $(patsubst %/,%,$(abspath $(shell pwd))/Build/$(CPU_TARGET))

HEADERS := $(wildcard *.h */*.h */*/*.h */*/*/*.h)
C_FILES := $(wildcard *.c */*.c */*/*.c */*/*/*.c)
CPP_FILES := $(wildcard *.cpp */*.cpp */*/*.cpp */*/*/*.cpp)
INO_FILES := $(wildcard *.ino)
ASM_FILES := $(wildcard *.s */*.s */*/*.s */*/*/*.s)

PROJECT_PATH := $(patsubst %/,%,$(abspath $(dir $(firstword $(MAKEFILE_LIST)))))
INO_FILE := $(shell pushd $(PROJECT_PATH) > /dev/null; ls --color=never *.ino | head -n 1; popd > /dev/null)
CPU_TARGET := $(INO_FILE:%.ino=%)
ARDUINO_BUILD_SYSTEM_PATH := $(patsubst %/,%,$(abspath $(dir $(lastword $(MAKEFILE_LIST)))))
BOARDS_DIR := $(abspath Boards)
CPU_WAIT_FOR_BOARD_PORT := yes
CLEAN_CORE := yes

include $(ARDUINO_BUILD_SYSTEM_PATH)/Boards/$(CPU_DEVICE).mk
include $(ARDUINO_BUILD_SYSTEM_PATH)/../BuildSystem.mk
include $(MAKE_INC_PATH)/CPUFlags.mk

ifneq ($(strip $(CPU_DEVICE)),teensy32)
    # This is not the main CPU, it is a secondary Teensy board, used for controlling the
    # reset pin during development for more reliable uploads to the more exotic boards
    RESET_PORT ?= $(shell "$(abspath $(ARDUINO_PATH)/hardware/tools/teensy_ports)" -L | egrep "\(Teensy\s3.2\)" | sed -E 's%[a-zA-Z0-9\:]+\ ([a-zA-Z0-9\/\.]+)\ .*%\1%')
endif
