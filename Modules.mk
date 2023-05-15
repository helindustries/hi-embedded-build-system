# Build module lib names and directories
MODULES ?=
MODULES_NAMES := $(foreach mod,$(MODULES), $(firstword $(subst :, ,$(mod))))
MODULES_PATHS := $(foreach mod,$(MODULES), $(lastword $(subst :, ,$(mod))))
$(foreach mod,$(MODULES),$(eval MODULES_PATH_$(firstword $(subst :, ,$(mod))) = $(abspath $(lastword $(subst :, ,$(mod))))))
$(foreach mod,$(MODULES),$(eval MODULES_FILES_$(firstword $(subst :, ,$(mod))) = $(foreach ext,c cpp S h, $(wildcard $(abspath $(lastword $(subst :, ,$(mod))))/*.$(ext) $(abspath $(lastword $(subst :, ,$(mod))))/**/*.$(ext)))))
#MODULES_TARGETS = $(patsubst %,lib%-$(MCU).a.target, $(filter-out Core,$(MODULES_NAMES)))
MODULES_TARGETS := $(patsubst %,lib%-$(MCU).a.target, $(MODULES_NAMES))
MODULES_LIBS := $(MODULES_NAMES:%=$(BUILD_DIR)/lib%-$(MCU).a)
MODULES_BUILD_DIRS := $(MODULES_NAMES:%=$(BUILD_DIR)/%)

ifeq ($(strip $(USE_ARDUINO_CORE)),yes)
CORE_TARGET := libCore-$(MCU).a.target
CORE_BUILD_DIR := $(BUILD_DIR)/Core
CORE_LIB := $(BUILD_DIR)/libCore-$(MCU).a
MODULES_PATH_Core := $(CORE_PATH)
endif

modules: $(MODULES_TARGETS) | silent

.PHONY: modules
