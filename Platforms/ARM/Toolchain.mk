MCU_TOOLCHAIN := arm
ARM_COMPILERPATH ?= $(ARDUINO_PATH)/hardware/tools/arm/bin
MCU_TOOLCHAIN_OPTIONS := -DARDUINO_ARCH_ARM

# compiler setup
CC := $(ARM_COMPILERPATH)/arm-none-eabi-gcc
CXX := $(ARM_COMPILERPATH)/arm-none-eabi-g++
GDB := $(ARM_COMPILERPATH)/arm-none-eabi-gdb
AR := $(ARM_COMPILERPATH)/arm-none-eabi-gcc-ar
OBJCOPY := $(ARM_COMPILERPATH)/arm-none-eabi-objcopy
OBJDUMP := $(ARM_COMPILERPATH)/arm-none-eabi-objdump
SIZE := $(ARM_COMPILERPATH)/arm-none-eabi-size
START_GROUP := -Wl,--start-group
END_GROUP := -Wl,--end-group -Wl,-EL

# CPPFLAGS = compiler options for C and C++
CPPFLAGS += $(OPTIMIZE) -Wall -ffunction-sections -fdata-sections -nostdlib -MMD -mthumb -mcpu=$(CPUARCH) -mfp16-format=alternative
CPPFLAGS += --param max-inline-insns-single=500 -Wno-error=narrowing -fsingle-precision-constant $(MCU_OPTIONS)

# compiler options for C++ only
CXXFLAGS += -fno-exceptions -fpermissive -felide-constructors -fno-threadsafe-statics -fno-rtti

# compiler options for C only
CFLAGS +=

# linker options (--specs=nano.specs)
LDFLAGS += $(OPTIMIZE) -Wl,--gc-sections,--relax,--defsym=__rtc_localtime=$(shell date +%s) -mcpu=$(CPUARCH) -mthumb -fsingle-precision-constant
LDFLAGS += -Wl,--check-sections,--unresolved-symbols=report-all,--warn-common,--warn-section-align -T$(ARM_LD)

# additional libraries to link
LIBS += -lm -lstdc++
