MCU_TOOLCHAIN := arm
MCU_TOOLCHAIN_OPTIONS := -DARDUINO_ARCH_ARM

# Default to the Adafruit distribution instead of the Teensy version, the Teensy version
# in hardware/tools/arm/bin is 2016 and does not support C++17
ARM_COMPILERPATH ?= $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/adafruit/tools/arm-none-eabi-gcc"/*/"bin" 2>/dev/null | sort | tail -n 1))
ifeq ($(strip $(ARM_COMPILERPATH)),)
	ARM_COMPILERPATH ?= $(ARDUINO_PATH)/hardware/tools/arm/bin
endif

# compiler setup
CC := $(ARM_COMPILERPATH)/arm-none-eabi-gcc
CXX := $(ARM_COMPILERPATH)/arm-none-eabi-g++
GDB := $(ARM_COMPILERPATH)/arm-none-eabi-gdb
OBJCOPY := $(ARM_COMPILERPATH)/arm-none-eabi-objcopy
OBJDUMP := $(ARM_COMPILERPATH)/arm-none-eabi-objdump
SIZE := $(ARM_COMPILERPATH)/arm-none-eabi-size
AR := $(ARM_COMPILERPATH)/arm-none-eabi-ar
ifeq ($(strip $(shell $(LS) $(AR))),)
AR := $(ARM_COMPILERPATH)/arm-none-eabi-gcc-ar
endif

START_GROUP := -Wl,--start-group
END_GROUP ?= -Wl,--end-group

# CPPFLAGS = compiler options for C and C++
CPPFLAGS += $(OPTIMIZE) -mcpu=$(CPUARCH) -mthumb -mfp16-format=alternative -nostdlib -MMD --param max-inline-insns-single=500
CPPFLAGS += -Wno-error=narrowing -Wall $(MCU_OPTIONS) -fsingle-precision-constant -ffunction-sections -fdata-sections

# compiler options for C++ only
CXXFLAGS += -fno-exceptions -fno-rtti -fpermissive -felide-constructors

# linker options (--specs=nano.specs)
LDFLAGS += $(OPTIMIZE) -mcpu=$(CPUARCH) -mthumb -mfp16-format=alternative
LDFLAGS += -save-temps --specs=nano.specs --specs=nosys.specs -T$(ARM_LD)
LDFLAGS += -Wl,--cref,--relax,--gc-sections,--defsym=__rtc_localtime=$(shell date +%s),--check-sections
LDFLAGS += -Wl,--unresolved-symbols=report-all,--warn-common

# additional libraries to link
LIBS += m stdc++

ifeq ($(strip $(ARM_USE_CMSIS)),yes)
	ARM_CMSIS_COMPONENTS ?= Core Driver DSP

	HEADERS += $(wildcard $(ARM_CMSIS_COMPONENTS:%=$(ARM_CMSIS_PATH)/%/Include/*.h $(ARM_CMSIS_PATH)/%/Include/*/*.h $(ARM_CMSIS_PATH)/%/Include/*/*/*.h $(ARM_CMSIS_PATH)/%/Include/*/*/*/*.h))
	C_FILES += $(wildcard $(ARM_CMSIS_COMPONENTS:%=$(ARM_CMSIS_PATH)/%/Source/*.c $(ARM_CMSIS_PATH)/%/Source/*/*.c $(ARM_CMSIS_PATH)/%/Source/*/*/*.c $(ARM_CMSIS_PATH)/%/Source/*/*/*/*.c))
	CPP_FILES += $(wildcard $(ARM_CMSIS_COMPONENTS:%=$(ARM_CMSIS_PATH)/%/Source/*.cpp $(ARM_CMSIS_PATH)/%/Source/*/*.cpp $(ARM_CMSIS_PATH)/%/Source/*/*/*.cpp $(ARM_CMSIS_PATH)/%/Source/*/*/*/*.cpp))
	ASM_FILES += $(wildcard $(ARM_CMSIS_COMPONENTS:%=$(ARM_CMSIS_PATH)/%/Source/*.S $(ARM_CMSIS_PATH)/%/Source/*/*.S $(ARM_CMSIS_PATH)/%/Source/*/*/*.S $(ARM_CMSIS_PATH)/%/Source/*/*/*/*.S))

	INCLUDE_PATHS += $(ARM_CMSIS_COMPONENTS:%="$(ARM_CMSIS_PATH)/%/Include")
	INCLUDE_PATHS += "$(ARM_CMSIS_DEVICE_PATH)"
endif
