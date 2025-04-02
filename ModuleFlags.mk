MODULE_BUILD_PATH := $(BUILD_DIR)/$(MODULE_NAME)
MODULE_H_FILES := $(filter-out $(MODULE_PATH)/examples/%,$(filter-out $(MODULE_PATH)/Examples/%,$(wildcard $(MODULE_PATH)/*.h $(MODULE_PATH)/*/*.h $(MODULE_PATH)/*/*/*.h $(MODULE_PATH)/*/*/*/*.h $(MODULE_PATH)/*/*/*/*/*.h $(MODULE_PATH)/*/*/*/*/*/*.h)))
MODULE_C_FILES := $(filter-out $(MODULE_PATH)/examples/%,$(filter-out $(MODULE_PATH)/Examples/%,$(wildcard $(MODULE_PATH)/*.c $(MODULE_PATH)/*/*.c $(MODULE_PATH)/*/*/*.c $(MODULE_PATH)/*/*/*/*.c $(MODULE_PATH)/*/*/*/*/*.c $(MODULE_PATH)/*/*/*/*/*/*.c)))
MODULE_CPP_FILES := $(filter-out $(MODULE_PATH)/examples/%,$(filter-out $(MODULE_PATH)/Examples/%,$(wildcard $(MODULE_PATH)/*.cpp $(MODULE_PATH)/*/*.cpp $(MODULE_PATH)/*/*/*.cpp $(MODULE_PATH)/*/*/*/*.cpp $(MODULE_PATH)/*/*/*/*/*.c $(MODULE_PATH)/*/*/*/*/*/*.cpp)))
MODULE_ASM_FILES := $(filter-out $(MODULE_PATH)/examples/%,$(filter-out $(MODULE_PATH)/Examples/%,$(wildcard $(MODULE_PATH)/*.S $(MODULE_PATH)/*.s $(MODULE_PATH)/*/*.S $(MODULE_PATH)/*/*/*.S $(MODULE_PATH)/*/*/*/*.S $(MODULE_PATH)/*/*/*/*/*.S $(MODULE_PATH)/*/*/*/*/*/*.S $(MODULE_PATH)/*/*.s $(MODULE_PATH)/*/*/*.s $(MODULE_PATH)/*/*/*/*.s $(MODULE_PATH)/*/*/*/*/*.s $(MODULE_PATH)/*/*/*/*/*/*.s)))

ifeq ($(strip $(MODULE_NAME)),ArduinoCore)
	ifneq ($(strip $(USE_ARDUINO_MAIN)),yes)
		MODULE_C_FILES := $(filter-out $(MODULE_PATH)/main.c,$(MODULE_C_FILES))
		MODULE_CPP_FILES := $(filter-out $(MODULE_PATH)/main.cpp,$(MODULE_CPP_FILES))

		ifeq ($(strip $(CORE_SKIP_NEW_O)),yes)
			MODULE_C_FILES := $(filter-out $(MODULE_PATH)/new.c,$(MODULE_C_FILES))
			MODULE_CPP_FILES := $(filter-out $(MODULE_PATH)/new.cpp,$(MODULE_CPP_FILES))
		endif
	endif
endif

MODULE_SOURCES += $(MODULE_H_FILES) $(MODULE_C_FILES) $(MODULE_CPP_FILES) $(MODULE_ASM_FILES)
MODULE_OBJS := $(MODULE_C_FILES:$(MODULE_PATH)/%.c=$(MODULE_BUILD_PATH)/%.o) $(MODULE_CPP_FILES:$(MODULE_PATH)/%.cpp=$(MODULE_BUILD_PATH)/%.o) $(MODULE_ASM_FILES:$(MODULE_PATH)/%.S=$(MODULE_BUILD_PATH)/%.o) $(MODULE_ASM_FILES:$(MODULE_PATH)/%.s=$(MODULE_BUILD_PATH)/%.o)
MODULE_LIB := $(BUILD_DIR)/lib$(MODULE_NAME)-$(CPU).a
