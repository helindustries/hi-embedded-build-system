# This is a special toolchain, coupled with a properly set up compatibility implementation,
# this can be used to run the MCU code on the host system for testing and tools integration.
MCU := Host
CPU_SPEED := 1
BUS_SPEED := 1
MCU_TOOLCHAIN := host
CORE_PLATFORM := Host

# compiler setup
CC := $(shell which clang)
CXX := $(shell which clang++)
GDB := $(shell which lldb)
AR := $(shell which ar)
OBJCOPY := $(shell which objcopy)
OBJDUMP := $(shell which objdump)
SIZE := $(shell which size)
ARFLAGS := -rcs
ifneq ($(strip $(LLVM_PREFIX)),)
CC := $(LLVM_PREFIX)/bin/clang
CXX := $(LLVM_PREFIX)/bin/clang++
GDB := $(LLVM_PREFIX)/bin/lldb
AR := $(LLVM_PREFIX)/bin/llvm-ar
OBJCOPY := $(LLVM_PREFIX)/bin/llvm-objcopy
OBJDUMP := $(LLVM_PREFIX)/bin/llvm-objdump
SIZE := $(LLVM_PREFIX)/bin/llvm-size
endif

# CPPFLAGS = compiler options for C and C++
CPPFLAGS += $(OPTIMIZE) -Wall -ffunction-sections -fdata-sections -Wno-error=narrowing -DHOST_PLATFORM
#CPPFLAGS += -mavx512fp16

# compiler options for C++ only
CXXFLAGS += -fno-exceptions -fpermissive -felide-constructors -fno-threadsafe-statics -std=gnu++17 -fno-rtti

# compiler options for C only
CFLAGS +=

# linker options (--specs=nano.specs)
LDFLAGS += $(OPTIMIZE) -fsingle-precision-constant

# additional libraries to link
LIBS += m stdc++

# automatically create lists of the sources and objects
SOURCES := $(C_FILES) $(CPP_FILES) $(INO_FILES) $(ASM_FILES) $(HEADERS)
# $(wildcard $(MODULES_PATHS:%,%/*.c) $(MODULES:%,%/*.cpp) $(MODULES:%,%/*.S) $(MODULES:%,%/*.h))
OBJS := $(C_FILES:%.c=$(BUILD_DIR)/%.o) $(CPP_FILES:%.cpp=$(BUILD_DIR)/%.o) $(INO_FILES:%.ino=$(BUILD_DIR)/%.o) $(ASM_FILES:%.s=$(BUILD_DIR)/%.o)
