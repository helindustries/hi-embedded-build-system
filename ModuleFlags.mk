MODULE_BUILD_PATH := $(BUILD_DIR)/$(MODULE_NAME)
MODULE_H_FILES := $(filter-out $(MODULE_PATH)/examples/%,$(wildcard $(MODULE_PATH)/*.h $(MODULE_PATH)/src/*.h $(MODULE_PATH)/src/**/*.h))
MODULE_C_FILES := $(filter-out $(MODULE_PATH)/examples/%,$(wildcard $(MODULE_PATH)/*.c $(MODULE_PATH)/src/*.c $(MODULE_PATH)/src/**/*.c))
MODULE_CPP_FILES := $(filter-out $(MODULE_PATH)/examples/%,$(wildcard $(MODULE_PATH)/*.cpp $(MODULE_PATH)/src/*.cpp $(MODULE_PATH)/src/**/*.cpp))
MODULE_ASM_FILES := $(filter-out $(MODULE_PATH)/examples/%,$(wildcard $(MODULE_PATH)/*.S $(MODULE_PATH)/src/*.S $(MODULE_PATH)/src/**/*.S))

ifeq ($(strip $(MODULE_NAME)),Core)
	ifneq ($(strip $(USE_ARDUINO_MAIN)),yes)
		MODULE_C_FILES := $(filter-out $(MODULE_PATH)/main.c,$(MODULE_C_FILES))
		MODULE_CPP_FILES := $(filter-out $(MODULE_PATH)/main.cpp,$(MODULE_CPP_FILES))
	endif
endif

MODULE_SOURCES += $(MODULE_H_FILES) $(MODULE_C_FILES) $(MODULE_CPP_FILES) $(MODULE_ASM_FILES)
MODULE_OBJS := $(MODULE_C_FILES:$(MODULE_PATH)/%.c=$(MODULE_BUILD_PATH)/%.o) $(MODULE_CPP_FILES:$(MODULE_PATH)/%.cpp=$(MODULE_BUILD_PATH)/%.o) $(MODULE_ASM_FILES:$(MODULE_PATH)/%.S=$(MODULE_BUILD_PATH)/%.o)
MODULE_LIB := $(BUILD_DIR)/lib$(MODULE_NAME)-$(MCU).a
