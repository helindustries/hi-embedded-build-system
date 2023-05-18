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
	CORE_TARGET := libCore-$(MCU).a.module
CORE_BUILD_DIR := $(BUILD_DIR)/Core
CORE_LIB := $(BUILD_DIR)/libCore-$(MCU).a
MODULES_PATH_Core := $(CORE_PATH)
endif

modules: $(MODULES_TARGETS) | silent

lib%-$(MCU).a.module:
ifeq ($(strip $(VERBOSE)),1)
	@$(VMSG) "Building Module lib$*-$(MCU).a.module"
	@$(VCFGMSG) "SUBTARGET_NAME:" "$*"
	@$(VCFGMSG) "SUBTARGET_PATH:" "$(MODULES_PATH_$*)"
	@$(VCFGMSG) "MAKE_INC_PATH:" "$(MAKE_INC_PATH)"
	@$(VCFGMSG) "BUILD_DIR:" "$(BUILD_DIR)"
	@$(VCFGMSG) "MCU:" "$(MCU)"
	@$(VCFGMSG) "CC:" "$(CC)"
	@$(VCFGMSG) "CXX:" "$(CXX)"
	@$(VCFGMSG) "AR:" "$(AR)"
endif
	$(V)$(MAKE) --directory="$(MODULES_PATH_$*)" --file "$(MAKE_INC_PATH)/ModulesMakefile.mk" "SUBTARGET_NAME=$*" "SUBTARGET_PATH=$(MODULES_PATH_$*)" "MAKE_INC_PATH=$(MAKE_INC_PATH)" "BUILD_DIR=$(BUILD_DIR)" "MCU=$(MCU)" "CFLAGS=$(CFLAGS)" "CPPFLAGS=$(CPPFLAGS)" "CORE_SKIP_NEW_O=$(CORE_SKIP_NEW_O)" "CXXFLAGS=$(CXXFLAGS)" "LDFLAGS=$(LDFLAGS)" "CC=$(CC)" "CXX=$(CXX)" "AR=$(AR)" "V=$(V)" 'MSG=$(MSG)' all

clean-modules:
ifneq ($(strip $(MODULES_BUILD_DIRS)),)
	$(V)rm -fr $(MODULES_BUILD_DIRS)
endif
ifneq ($(strip $(CORE_BUILD_DIR)),)
ifeq ($(strip $(CLEAN_CORE)),yes)
	$(V)rm -fr $(CORE_BUILD_DIR)
endif
endif
ifneq ($(strip $(MODULES_LIBS)),)
	$(V)rm -f $(MODULES_LIBS)
endif
ifneq ($(strip $(CORE_LIB)),)
	$(V)rm -f $(CORE_LIB)
endif

.PHONY: modules clean-modules
