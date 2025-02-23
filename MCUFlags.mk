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

CORE_PLATFORM_UPPER := $(shell echo $(CORE_PLATFORM) | tr '[:lower:]' '[:upper:]')
ASMFLAGS += -x assembler-with-cpp
CPPFLAGS += -DF_CPU=$(F_CPU) $(MCU_BOARD_OPTS) -D__$(MCU_UPPER)__
CPPFLAGS += -DCORE_PLATFORM_$(CORE_PLATFORM_UPPER) -DCORE_PLATFORM=\"$(CORE_PLATFORM)\"
CPPFLAGS += -DCPU_NAME=\"$(strip $(MCU_UPPER))\" -DBOARD_NAME=\"$(strip $(MCU_BOARD))\"
CPPFLAGS += -DHI_MAKEFILE_BUILDSYSTEM
ifneq ($(strip $(BUS_SPEED)),)
	CPPFLAGS += -DF_BUS=$(F_BUS)
endif
ifeq ($(strip $(USB)),yes)
    CPPFLAGS += -DUSBCON -DUSB_CONFIG_POWER=100 "-DUSB_NAME=\"$(USB_VENDOR)_$(USB_PRODUCT)\""
    CPPFLAGS += -DUSB_VID=$(USB_VID) -DUSB_PID=$(USB_PID)
    CPPFLAGS += "-DUSB_MANUFACTURER=\"$(USB_VENDOR)\"" "-DUSB_PRODUCT=\"$(USB_PRODUCT)\""
else
ifeq ($(strip $(USB)),nodefine)
    CPPFLAGS += -DUSBCON -DUSB_CONFIG_POWER=100 "-DUSB_NAME=\"$(USB_VENDOR)_$(USB_PRODUCT)\""
endif
endif

# Base Arduino compatibility
ifeq ($(strip $(USE_ARDUINO_CORE)),yes)
    CPPFLAGS += -DARDUINO=10812 -DARDUINO_ARCH_$(CORE_PLATFORM_UPPER)
    CPPFLAGS += -DARDUINO_$(strip $(MCU_BOARD_UPPER)) -DARDUINO_BOARD=\"$(strip $(MCU_BOARD_UPPER))\"

    ifneq ($(strip $(ARDUINO_VARIANT_NAME)),)
    	CPPFLAGS += -DARDUINO_VARIANT=\"$(ARDUINO_VARIANT_NAME)\"
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
