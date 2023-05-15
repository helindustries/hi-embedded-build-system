MODULE_NAME := $(SUBTARGET_NAME)
MODULE_PATH := $(SUBTARGET_PATH)
include $(MAKE_INC_PATH)/Common.mk
include $(MAKE_INC_PATH)/ModuleFlags.mk
include $(MAKE_INC_PATH)/ModuleTargets.mk

all: $(MODULE_LIB) | silent

.PHONY: all
