CPU_DEVICE ?= teensy36
CPU_TARGET ?= $(basename $(realpath $(abspath .)))
OPTIMIZE ?= -Os
ELF_MAP ?=
BINARY_DEPS ?=

CPU_USE_JTAG ?=
CPU_JTAG_UPLOAD_TARGET :=
CPU_DEBUG_TARGET := $(CPU_DEVICE)
ifeq ($(strip $(CPU_USE_JTAG)), yes)
	CPU_JTAG_UPLOAD_TARGET = _jtag
endif

INCLUDE_PATHS += "$(abspath $(MAKE_BASE_PATH))"

# Project-specific board definitions
ifneq ($(strip $(DEVICES_DIR)),)
    HEADERS -= $(filter $(wildcard $(DEVICES_DIR)/*.h),$(HEADERS))
    CPP_FILES -= $(filter $(wildcard $(DEVICES_DIR)/*.cpp),$(CPP_FILES))
    C_FILES -= $(filter $(wildcard $(DEVICES_DIR)/*.c),$(C_FILES))
    ASM_FILES -= $(filter $(wildcard $(DEVICES_DIR)/*.s),$(ASM_FILES))
    ASM_FILES -= $(filter $(wildcard $(DEVICES_DIR)/*.S),$(ASM_FILES))

    HEADERS += $(wildcard $(DEVICES_DIR)/$(CPU_DEVICE)/*.h)
    CPP_FILES += $(wildcard $(DEVICES_DIR)/$(CPU_DEVICE)/*.cpp)
    C_FILES += $(wildcard $(DEVICES_DIR)/$(CPU_DEVICE)/*.c)
    ASM_FILES += $(wildcard $(DEVICES_DIR)/$(CPU_DEVICE)/*.s)
    ASM_FILES += $(wildcard $(DEVICES_DIR)/$(CPU_DEVICE)/*.S)

    INCLUDE_PATHS += "$(DEVICES_DIR)/$(CPU_DEVICE)"
endif

include $(MAKE_INC_PATH)/Devices/CPU/$(CPU_DEVICE).mk

CPU_UPPER := $(shell echo $(CPU) | tr '[:lower:]' '[:upper:]')
CPU_DEVICE_UPPER := $(subst -,_,$(shell echo $(CPU_DEVICE) | tr '[:lower:]' '[:upper:]'))
CPU_ARCH := $(shell echo $(CPU_TOOLCHAIN) | tr '[:lower:]' '[:upper:]')

F_CPU := $(CPU_SPEED)000000
F_BUS := $(BUS_SPEED)000000

CORE_PLATFORM_UPPER := $(shell echo $(CORE_PLATFORM) | tr '[:lower:]' '[:upper:]')
ASMFLAGS += -x assembler-with-cpp
CPPFLAGS += -DF_CPU=$(F_CPU) $(CPU_DEVICE_OPTS) -D__$(CPU_UPPER)__
CPPFLAGS += -DCORE_PLATFORM_$(CORE_PLATFORM_UPPER) -DCORE_PLATFORM=\"$(CORE_PLATFORM)\"
CPPFLAGS += -DCPU_NAME=\"$(strip $(CPU_UPPER))\" -DBOARD_NAME=\"$(strip $(CPU_DEVICE))\"
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
    CPPFLAGS += -DARDUINO_$(strip $(CPU_DEVICE_UPPER)) -DARDUINO_BOARD=\"$(strip $(CPU_DEVICE_UPPER))\"

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
