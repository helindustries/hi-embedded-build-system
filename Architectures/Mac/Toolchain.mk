# This is a special toolchain, coupled with a properly set up compatibility implementation,
# this can be used to run the CPU code on the host system for testing and tools integration.
CPU := arm64
CPUARCH := armv8-a
CPU_SPEED := 1
BUS_SPEED := 1
CPU_TOOLCHAIN := $(PLATFORM_ID)
CPU_TOOLCHAIN_UPPER := $(call upper,"$(CPU_TOOLCHAIN)")
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
CPPFLAGS += -I$(GCC_PREFIX)/include
LDFLAGS += -L$(GCC_PREFIX)/lib
else
ifeq ($(strip $(LLVM_PREFIX)),)
CC := $(call which,clang)
CXX := $(call which,clang++)
GDB := $(call which,lldb)
AR := $(call which,ar)
OBJCOPY := $(call which,objcopy)
OBJDUMP := $(call which,objdump)
SIZE := $(call which,size)
else
CC := $(LLVM_PREFIX)/bin/clang
CXX := $(LLVM_PREFIX)/bin/clang++
GDB := $(LLVM_PREFIX)/bin/lldb
ifneq ($(call exists,$(LLVM_PREFIX)/bin/llvm-ar),)
    AR := $(LLVM_PREFIX)/bin/llvm-ar
else
	AR := $(LLVM_PREFIX)/bin/ar
endif
ifneq ($(call exists,$(LLVM_PREFIX)/bin/llvm-objcopy),)
	OBJCOPY := $(LLVM_PREFIX)/bin/llvm-objcopy
else
	OBJCOPY := $(LLVM_PREFIX)/bin/objcopy
endif
ifneq ($(call exists,$(LLVM_PREFIX)/bin/llvm-objdump),)
	OBJDUMP := $(LLVM_PREFIX)/bin/llvm-objdump
else
	OBJDUMP := $(LLVM_PREFIX)/bin/objdump
endif
ifneq ($(call exists,$(LLVM_PREFIX)/bin/llvm-size),)
	SIZE := $(LLVM_PREFIX)/bin/llvm-size
else
	SIZE := $(LLVM_PREFIX)/bin/size
endif
CPPFLAGS += -I$(LLVM_PREFIX)/include
LDFLAGS += -L$(LLVM_PREFIX)/lib
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
