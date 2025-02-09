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

INCLUDE_PATHS += "$(abspath $(MAKE_BASE_PATH))"

# Project-specific board definitions
ifneq ($(strip $(BOARDS_DIR)),)
	HEADERS -= $(filter $(wildcard $(BOARDS_DIR)/*.h),$(HEADERS))
	CPP_FILES -= $(filter $(wildcard $(BOARDS_DIR)/*.cpp),$(CPP_FILES))
	C_FILES -= $(filter $(wildcard $(BOARDS_DIR)/*.c),$(C_FILES))
	ASM_FILES -= $(filter $(wildcard $(BOARDS_DIR)/*.s),$(ASM_FILES))
	ASM_FILES -= $(filter $(wildcard $(BOARDS_DIR)/*.S),$(ASM_FILES))

	HEADERS += $(wildcard $(BOARDS_DIR)/$(MCU_BOARD)/*.h)
	CPP_FILES += $(wildcard $(BOARDS_DIR)/$(MCU_BOARD)/*.cpp)
	C_FILES += $(wildcard $(BOARDS_DIR)/$(MCU_BOARD)/*.c)
	ASM_FILES += $(wildcard $(BOARDS_DIR)/$(MCU_BOARD)/*.s)
	ASM_FILES += $(wildcard $(BOARDS_DIR)/$(MCU_BOARD)/*.S)

	INCLUDE_PATHS += "$(BOARDS_DIR)/$(MCU_BOARD)"
endif

include $(MAKE_INC_PATH)/Targets/MCU/$(MCU_BOARD).mk

MCU_UPPER := $(shell echo $(MCU) | tr '[:lower:]' '[:upper:]')
MCU_BOARD_UPPER := $(subst -,_,$(shell echo $(MCU_BOARD) | tr '[:lower:]' '[:upper:]'))
MCU_ARCH := $(shell echo $(MCU_TOOLCHAIN) | tr '[:lower:]' '[:upper:]')

F_CPU := $(CPU_SPEED)000000
F_BUS := $(BUS_SPEED)000000

CPPFLAGS += -D__$(MCU_UPPER)__ -DF_CPU=$(F_CPU) $(MCU_BOARD_OPTS) -DCORE_PLATFORM_$(CORE_PLATFORM)
ASMFLAGS += -x assembler-with-cpp
ifneq (BUS_SPEED,)
	CPPFLAGS += -DF_BUS=$(F_BUS)
endif

# Base Arduino compatibility
ifeq ($(strip $(USE_ARDUINO_CORE)),yes)
	CPPFLAGS += -DARDUINO=10812 -DTEENSYDUINO=151 -DARDUINO_$(strip $(MCU_BOARD_UPPER)) -DARDUINO_BOARD=\"$(strip $(MCU_BOARD_UPPER))\" -DARDUINO_ARCH_$(CORE_PLATFORM)

	ifneq ($(strip $(ARDUINO_VARIANT_NAME)),)
		ifneq ($(strip $(CORE_VARIANTS_PATH)),)
			INCLUDE_PATHS += "$(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)"
			LIBRARY_PATHS += "$(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)"

			HEADERS += $(wildcard $(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/*.h)
			CPP_FILES += $(wildcard $(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/*.cpp)
			C_FILES += $(wildcard $(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/*.c)
			ASM_FILES += $(wildcard $(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/*.s)
		endif
	endif
endif