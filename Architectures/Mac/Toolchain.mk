# This is a special toolchain, coupled with a properly set up compatibility implementation,
# this can be used to run the CPU code on the host system for testing and tools integration.
CPU := arm64
CPUARCH := armv8-a
CPU_SPEED := 1
BUS_SPEED := 1
CPU_TOOLCHAIN := $(PLATFORM_ID)
CPU_TOOLCHAIN_UPPER := $(shell echo $(CPU_TOOLCHAIN) | tr '[:lower:]' '[:upper:]')
CPU_BINARY_EXT := .mach-o

# compiler setup
ifeq ($(strip $(FORCE_GCC)),yes)
CC := $(GCC_PREFIX)/bin/gcc
CXX := $(GCC_PREFIX)/bin/g++
GDB := $(GCC_PREFIX)/bin/gdb
AR := $(GCC_PREFIX)/bin/ar
OBJCOPY := $(GCC_PREFIX)/bin/objcopy
OBJDUMP := $(GCC_PREFIX)/bin/objdump
SIZE := $(GCC_PREFIX)/bin/size
else
ifeq ($(strip $(LLVM_PREFIX)),)
CC := $(shell which clang)
CXX := $(shell which clang++)
GDB := $(shell which lldb)
AR := $(shell which ar)
OBJCOPY := $(shell which objcopy)
OBJDUMP := $(shell which objdump)
SIZE := $(shell which size)
else
CC := $(LLVM_PREFIX)/bin/clang
CXX := $(LLVM_PREFIX)/bin/clang++
GDB := $(LLVM_PREFIX)/bin/lldb
AR := $(LLVM_PREFIX)/bin/llvm-ar
OBJCOPY := $(LLVM_PREFIX)/bin/llvm-objcopy
OBJDUMP := $(LLVM_PREFIX)/bin/llvm-objdump
SIZE := $(LLVM_PREFIX)/bin/llvm-size
endif
endif

# CPPFLAGS = compiler options for C and C++
CPPFLAGS += $(OPTIMIZE) -Wall -ffunction-sections -fdata-sections -Wno-error=narrowing
CPPFLAGS += -DARDUINO_ARCH_MACOS -D$(CPU_TOOLCHAIN_UPPER)=1
#CPPFLAGS += -mavx512fp16

# compiler options for C++ only
CXXFLAGS += -fno-exceptions -fpermissive -felide-constructors -fno-threadsafe-statics -fno-rtti

# compiler options for C only
CFLAGS +=

# linker options (--specs=nano.specs)
LDFLAGS += $(OPTIMIZE) -fsingle-precision-constant

ARFLAGS := -rcs

# additional libraries to link
LIBS += m stdc++

# automatically create lists of the sources and objects
#SOURCES := $(C_FILES) $(CPP_FILES) $(INO_FILES) $(ASM_FILES) $(HEADERS)
# $(wildcard $(MODULES_PATHS:%,%/*.c) $(MODULES:%,%/*.cpp) $(MODULES:%,%/*.S) $(MODULES:%,%/*.h))
#OBJS := $(C_FILES:%.c=$(BUILD_DIR)/%.o) $(CPP_FILES:%.cpp=$(BUILD_DIR)/%.o) $(INO_FILES:%.ino=$(BUILD_DIR)/%.o) $(ASM_FILES:%.s=$(BUILD_DIR)/%.o)
