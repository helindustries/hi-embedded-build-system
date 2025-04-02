# Build module lib names and directories
MODULES ?=
$(foreach mod,$(MODULES),$(eval MODULES = $(patsubst $(mod),$(if $(wildcard $(abspath $(lastword $(subst :, ,$(mod))))/src),$(mod)/src,$(mod)),$(MODULES))))
MODULES_NAMES := $(foreach mod,$(MODULES),$(firstword $(subst :, ,$(mod))))
MODULES_PATHS := $(foreach mod,$(MODULES),$(lastword $(subst :, ,$(mod))))
$(foreach mod,$(MODULES),$(eval MODULES_PATH_$(firstword $(subst :, ,$(mod))) = $(abspath $(lastword $(subst :, ,$(mod))))))
$(foreach mod,$(MODULES),$(eval MODULES_FILES_$(firstword $(subst :, ,$(mod))) = $(foreach ext,c cpp S s h, $(wildcard $(abspath $(lastword $(subst :, ,$(mod))))/*.$(ext) $(abspath $(lastword $(subst :, ,$(mod))))/**/*.$(ext)))))
$(foreach mod,$(MODULES),$(eval MODULES_FILES_$(firstword $(subst :, ,$(mod))) = $(filter-out Examples/%,$(filter-out examples/%,$(MODULES_FILES_$(firstword $(subst :, ,$(mod))))))))
MODULES_TARGETS := $(patsubst %,lib%-$(CPU).a.module, $(MODULES_NAMES))
MODULES_CFG_TARGETS := $(patsubst %,lib%-$(CPU).a.modulecfg, $(MODULES_NAMES))
MODULES_LIBS := $(MODULES_NAMES:%=$(BUILD_DIR)/lib%-$(CPU).a)
MODULES_BUILD_DIRS := $(MODULES_NAMES:%=$(BUILD_DIR)/%)
CPPFLAGS += $(MODULES_PATHS:%="-I%")

ifeq ($(strip $(USE_ARDUINO_CORE)),yes)
    CORE_TARGET := libArduinoCore-$(CPU).a.module
    CORE_BUILD_DIR := $(BUILD_DIR)/ArduinoCore
    CORE_LIB := $(BUILD_DIR)/libArduinoCore-$(CPU).a
    MODULES_CFG_TARGETS += $(CORE_TARGET)cfg
    MODULES_PATH_ArduinoCore := $(CORE_PATH)
    ifneq ($(strip $(CORE_PATH)),)
        CPPFLAGS += "-I$(CORE_PATH)"
    endif
endif

modules: $(MODULES_TARGETS) | silent

lib%-$(CPU).a.module:
ifeq ($(strip $(VERBOSE)),1)
	@$(VMSG) "Building Module lib$*-$(CPU).a.module"
	@$(VCFGMSG) 'SUBTARGET_NAME:' '$*'
	@$(VCFGMSG) 'SUBTARGET_PATH:' '$(MODULES_PATH_$*)'
	@$(VCFGMSG) 'MAKE_INC_PATH:' '$(MAKE_INC_PATH)'
	@$(VCFGMSG) 'BUILD_DIR:' '$(BUILD_DIR)'
	@$(VCFGMSG) 'CPU:' '$(CPU)'
	@$(VCFGMSG) 'CC:' '$(CC)'
	@$(VCFGMSG) 'CXX:' '$(CXX)'
	@$(VCFGMSG) 'AR:' '$(AR)'
endif
	$(V)$(MAKE) --directory='$(MODULES_PATH_$*)' --file='$(MAKE_INC_PATH)/ModulesMakefile.mk' 'SUBTARGET_NAME=$*' 'SUBTARGET_PATH=$(MODULES_PATH_$*)' 'MAKE_INC_PATH=$(MAKE_INC_PATH)' 'BUILD_DIR=$(BUILD_DIR)' 'CPU=$(CPU)' 'CFLAGS=$(CFLAGS)' 'CPPFLAGS=$(CPPFLAGS)' 'ARFLAGS=$(ARFLAGS)' 'USE_ARDUINO_MAIN=$(USE_ARDUINO_MAIN)' 'CORE_SKIP_NEW_O=$(CORE_SKIP_NEW_O)' 'CXXFLAGS=$(CXXFLAGS)' 'LDFLAGS=$(LDFLAGS)' 'ASMFLAGS=$(ASMFLAGS)' 'CC=$(CC)' 'CXX=$(CXX)' 'AR=$(AR)' 'V=$(V)' 'MSG=$(MSG)' $(MAKEFLAGS) all

cfg-modules: --cfg-modules $(MODULES_CFG_TARGETS) libArduinoCore-$(CPU).a.modulecfg
--cfg-modules:
	@$(MSG) "[CFG]" "$(CPU_TARGET) Modules"
	@$(CFGMSG) 'MODULES:' '$(MODULES)'
	@$(CFGMSG) 'MODULES_NAMES:' '$(MODULES_NAMES)'
	@$(CFGMSG) 'CFLAGS:' '$(CFLAGS)'
	@$(CFGMSG) 'CPPFLAGS:' '$(CPPFLAGS)'
	@$(CFGMSG) 'CXXFLAGS:' '$(CXXFLAGS)'
	@$(CFGMSG) 'LDFLAGS:' '$(LDFLAGS)'
	@$(CFGMSG) 'ARFLAGS:' '$(LDFLAGS)'
	@$(CFGMSG) 'ASMFLAGS:' '$(LDFLAGS)'

lib%-$(CPU).a.modulecfg:
	$(V)$(MAKE) --directory='$(MODULES_PATH_$*)' --file='$(MAKE_INC_PATH)/ModulesMakefile.mk' 'SUBTARGET_NAME=$*' 'SUBTARGET_PATH=$(MODULES_PATH_$*)' 'MAKE_INC_PATH=$(MAKE_INC_PATH)' 'BUILD_DIR=$(BUILD_DIR)' 'CPU=$(CPU)' 'CFLAGS=$(CFLAGS)' 'CPPFLAGS=$(CPPFLAGS)' 'ARFLAGS=$(ARFLAGS)' 'USE_ARDUINO_MAIN=$(USE_ARDUINO_MAIN)' 'CORE_SKIP_NEW_O=$(CORE_SKIP_NEW_O)' 'CXXFLAGS=$(CXXFLAGS)' 'LDFLAGS=$(LDFLAGS)' 'ASMFLAGS=$(ASMFLAGS)' 'CC=$(CC)' 'CXX=$(CXX)' 'AR=$(AR)' 'V=$(V)' 'MSG=$(MSG)' cfg

clean-modules:
	@$(MSG) "[CLEAN]" "$(CPU_TARGET)" "Modules"
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

.PHONY: modules clean-modules cfg-modules --cfg-modules

.NOTPARALLEL: cfg-modules
