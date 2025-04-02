QT_MODULES ?=
INCLUDE_PATHS += $(QT_TOOLCHAIN_PATH)/include $(QT_MODULES:%=$(QT_TOOLCHAIN_PATH)/include/%)
LIBRARY_PATHS += $(QT_TOOLCHAIN_PATH)/lib
QT_FRAMEWORK_INCLUDES +=
ifeq ($(strip $(shell uname -s)),Darwin)
    QT_FRAMEWORK_INCLUDES := $(QT_MODULES:%=$(BUILD_DIR)/Frameworks/%.timestamp)
    CPPFLAGS += "-I$(BUILD_DIR)/Frameworks" $(QT_MODULES:%="-I$(BUILD_DIR)/Frameworks/%")
    LDFLAGS += -F$(QT_TOOLCHAIN_PATH)/lib $(QT_MODULES:%=-framework %)
else
    LIBS += $(QT_MODULES)
endif

QT_TOOLCHAIN_BIN_PATH=$(QT_TOOLCHAIN_PATH)/libexec
UIC := $(QT_TOOLCHAIN_BIN_PATH)/uic
MOC := $(QT_TOOLCHAIN_BIN_PATH)/moc
RCC := $(QT_TOOLCHAIN_BIN_PATH)/rcc

# Define the generated files
QT_UIC_SOURCES := $(QT_UI_FILES:%.ui=$(BUILD_DIR)/%.ui.cpp)
QT_MOC_SOURCES := $(QT_HEADERS:%.h=$(BUILD_DIR)/%.moc.cpp)
QT_RCC_SOURCES := $(QT_RESOURCES:%.qrc=$(BUILD_DIR)/%.rcc.cpp)

# Extend sources and object files by the Qt files, sources do not contain the generated sources
SOURCES += $(QT_UI_FILES) $(QT_RESOURCES)
OBJS := $(QT_FRAMEWORK_INCLUDES) $(QT_UIC_SOURCES:%.cpp=%.o) $(QT_MOC_SOURCES:%.cpp=%.o) $(QT_RCC_SOURCES:%.cpp=%.o) $(OBJS)
