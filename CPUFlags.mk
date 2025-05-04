CPU_DEVICE ?= $(IN_CPU_DEVICE)
CPU_TARGET ?= $(IN_CPU_TARGET)
CPU_EXEC_OFFSET ?= $(IN_CPU_EXEC_OFFSET)
CPU_DEVICE_OPTS ?= $(IN_CPU_DEVICE_OPTS)
BUILD_DIR ?= $(IN_BUILD_DIR)

ifeq ($(strip $(CPU_DEVICE)),)
    $(error "CPU_DEVICE not set")
endif
ifeq ($(strip $(CPU_TARGET)),)
    $(error "CPU_TARGET not set")
endif

IN_OPTIMIZE ?= -Os
OPTIMIZE ?= $(IN_OPTIMIZE)
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
    HEADERS := $(filter-out $(DEVICES_DIR)/%,$(HEADERS))
    CPP_FILES := $(filter-out $(DEVICES_DIR)/%,$(CPP_FILES))
    C_FILES := $(filter-out $(DEVICES_DIR)/%,$(C_FILES))
    ASM_FILES := $(filter-out $(DEVICES_DIR)/%,$(ASM_FILES))
    ASM_FILES := $(filter-out $(DEVICES_DIR)/%,$(ASM_FILES))

    HEADERS += $(wildcard $(DEVICES_DIR)/$(CPU_DEVICE)/*.h)
    CPP_FILES += $(wildcard $(DEVICES_DIR)/$(CPU_DEVICE)/*.cpp)
    C_FILES += $(wildcard $(DEVICES_DIR)/$(CPU_DEVICE)/*.c)
    ASM_FILES += $(wildcard $(DEVICES_DIR)/$(CPU_DEVICE)/*.s)
    ASM_FILES += $(wildcard $(DEVICES_DIR)/$(CPU_DEVICE)/*.S)

    INCLUDE_PATHS += "$(DEVICES_DIR)/$(CPU_DEVICE)"
endif

include $(MAKE_INC_PATH)/Devices/CPU/$(CPU_DEVICE).mk

CPU_UPPER := $(call upper,"$(CPU)")
CPU_ARCH := $(call upper,"$(CPU_ARCH)")
CPU_DEVICE_UPPER := $(subst -,_,$(call upper,"$(CPU_DEVICE)"))

F_CPU := $(CPU_SPEED)000000
F_BUS := $(BUS_SPEED)000000

CORE_PLATFORM_UPPER := $(call upper,"$(CORE_PLATFORM)")
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
