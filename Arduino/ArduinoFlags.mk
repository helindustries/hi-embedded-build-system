USE_ARDUINO_MAIN = yes
USE_ARDUINO_CORE = yes
BUILD_DIR ?= $(patsubst %/,%,$(abspath $(shell pwd))/Build/$(MCU_TARGET))

HEADERS := $(wildcard *.h */*.h */*/*.h */*/*/*.h)
C_FILES := $(wildcard *.c */*.c */*/*.c */*/*/*.c)
CPP_FILES := $(wildcard *.cpp */*.cpp */*/*.cpp */*/*/*.cpp)
INO_FILES := $(wildcard *.ino)
ASM_FILES := $(wildcard *.s */*.s */*/*.s */*/*/*.s)

ifeq ($(strip $(MCU_BOARD)),feather-nrf52840)
    ARDUINO_VARIANT_NAME := feather_nrf52840_express
    MCU_WAIT_FOR_BOARD_PORT = yes
endif
ifeq ($(strip $(MCU_BOARD)),feather-m0)
    ARDUINO_VARIANT_NAME := feather_m0
endif
ifeq ($(strip $(MCU_BOARD)),feather-m0wifi)
    ARDUINO_VARIANT_NAME := feather_m0
    CPPFLAGS += -DADAFRUIT_FEATHER_M0WIFI -DADAFRUIT_ATWINC1500_PRESENT
endif
ifeq ($(strip $(MCU_BOARD)),feather-m0bluefruit)
    ARDUINO_VARIANT_NAME := feather_m0
    CPPFLAGS += -DADAFRUIT_FEATHER_M0BLUEFRUIT -DADAFRUIT_NRF51822_PRESENT
endif
ifeq ($(strip $(MCU_BOARD)),teensy36)
	MCU_WAIT_FOR_BOARD_PORT = yes
endif
ifeq ($(strip $(MCU_BOARD)),teensy32)
	MCU_WAIT_FOR_BOARD_PORT = yes
endif
ifeq ($(strip $(MCU_BOARD)),teensylc)
	MCU_WAIT_FOR_BOARD_PORT = yes
endif
ifeq ($(strip $(MCU_BOARD)),ulx3s)
    MCU_USE_TINYUF2 = no
    ARDUINO_VARIANT_NAME = lolin32
endif
ifeq ($(strip $(MCU_BOARD)),feather-esp32s3)
    FORCE_MCU_UPLOAD = yes
    MCU_USE_TINYUF2 = yes
    ARDUINO_VARIANT_NAME = adafruit_feather_esp32s3
endif
ifeq ($(strip $(MCU_BOARD)),feather-esp32s3-tft)
    FORCE_MCU_UPLOAD = yes
    MCU_USE_TINYUF2 = yes
    MCU_BOARD = feather-esp32s3
    ARDUINO_VARIANT_NAME = adafruit_feather_esp32s3_tft
    CPPFLAGS += -DADAFRUIT_FEATHER_ESP32S3_TFT
endif
ifeq ($(strip $(MCU_BOARD)),qtpy-esp32s3-psram)
    MCU_BOARD = qtpy-esp32s3
    ESP_WITH_PSRAM = yes
    ARDUINO_VARIANT_NAME = adafruit_qtpy_esp32s3_n4p2
endif
ifeq ($(strip $(MCU_BOARD)),qtpy-esp32s3)
    FORCE_MCU_UPLOAD = yes
    MCU_USE_TINYUF2 = yes
    MCU_BOARD = qtpy-esp32s3
    ARDUINO_VARIANT_NAME = adafruit_qtpy_esp32s3_nopsram
endif

PROJECT_PATH := $(patsubst %/,%,$(abspath $(dir $(firstword $(MAKEFILE_LIST)))))
INO_FILE := $(shell pushd $(PROJECT_PATH) > /dev/null; ls --color=never *.ino | head -n 1; popd > /dev/null)
MCU_TARGET := $(INO_FILE:%.ino=%)
ARDUINO_BUILD_SYSTEM_PATH := $(patsubst %/,%,$(abspath $(dir $(lastword $(MAKEFILE_LIST)))))

ifneq ($(strip $(MCU_BOARD)),teensy32)
    # This is not the main MCU, it is a secondary Teensy board, used for controlling the
    # reset pin during development for more reliable uploads to the more exotic boards
    RESET_PORT ?= $(shell "$(abspath $(ARDUINO_PATH)/hardware/tools/teensy_ports)" -L | egrep "\(Teensy\s3.2\)" | sed -E 's%[a-zA-Z0-9\:]+\ ([a-zA-Z0-9\/\.]+)\ .*%\1%')
endif

include $(ARDUINO_BUILD_SYSTEM_PATH)/../BuildSystem.mk
include $(MAKE_INC_PATH)/MCUFlags.mk
