MCU_BOARD ?= teensy36
MCU_TARGET ?= $(basename $(realpath $(abspath .)))
OPTIMIZE ?= -Os
ELF_MAP ?=
BINARY_DEPS ?=

MCU_USE_JTAG ?=
MCU_JTAG_UPLOAD_TARGET :=
MCU_DEBUG_TARGET := $(MCU_BOARD)
ifeq ($(strip $(MCU_USE_JTAG)), yes)
	MCU_JTAG_UPLOAD_TARGET = _jtag
endif

include $(MAKE_INC_PATH)/Targets/MCU/$(MCU_BOARD).mk

MCU_UPPER := $(shell echo $(MCU) | tr '[:lower:]' '[:upper:]')
MCU_BOARD_UPPER := $(subst -,_,$(shell echo $(MCU_BOARD) | tr '[:lower:]' '[:upper:]'))
MCU_ARCH := $(shell echo $(MCU_TOOLCHAIN) | tr '[:lower:]' '[:upper:]')

F_CPU := $(CPU_SPEED)000000
F_BUS := $(BUS_SPEED)000000

CPPFLAGS += -I "$(MAKE_BASE_PATH)/$(MCU_BOARD)" -D__$(MCU_UPPER)__ -D$(MCU_UPPER) -DF_CPU=$(F_CPU) $(MCU_BOARD_OPTS) -DCORE_PLATFORM_$(CORE_PLATFORM)
ifneq (BUS_SPEED,)
	CPPFLAGS += -DF_BUS=$(F_BUS)
endif

# Base Arduino compatibility
HEADERS += $(wildcard $(MCU_BOARD)/*.h)
CPP_FILES += $(wildcard $(MCU_BOARD)/*.cpp)
C_FILES += $(wildcard $(MCU_BOARD)/*.c)
ASM_FILES += $(wildcard $(MCU_BOARD)/*.s)
CPPFLAGS += -DARDUINO=10812 -DTEENSYDUINO=151 "-DARDUINO_$(strip $(MCU_BOARD_UPPER))" '-DARDUINO_BOARD="$(strip $(MCU_BOARD_UPPER))"'

ifneq ($(strip $(ARDUINO_VARIANT_NAME)),)
	CPPFLAGS += -I "$(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)"
endif
