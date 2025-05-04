export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

VERBOSE ?= 0
CFGMSG = printf "    %-30s %s\n"
ifneq "$(VERBOSE)" "1"
    V = @
    MSG = printf "  %-9s    %-20s  %s\n"
    FMSG = true
    VMSG = true
    VCFGMSG = true
else
    MSG = true
    FMSG = printf "%s\n"
    VMSG = printf "%s\n"
    VCFGMSG = printf "  %-9s %s\n"
endif

CPU_BASE_TARGET ?= $(CPU_TARGET)
HAS_UPLOAD_TARGET := $(filter upload upload-% %-upload %upload% install install-% %-install %install%,$(MAKECMDGOALS))

ifeq ($(OS),Windows_NT)
	WHICH ?= where
else
	WHICH ?= which
endif


ifneq ($(strip $(PYTHON_ADDITIONAL_PATHS)),)
    #PYTHON_PATH := $(strip $(call shell-list,$(PYTHON_ADDITIONAL_PATHS)))

    ifeq ($(strip $(shell echo $$PYTHONPATH)),)
        PYTHON_ENV += PYTHONPATH="$(PYTHON_PATH)"
    else
        PYTHON_ENV += PYTHONPATH="$(shell echo $$PYTHONPATH):$(PYTHON_PATH)"
    endif
endif

PYTHON := $(PYTHON_ENV) "$(shell $(WHICH) python)"

silent:
	@:

.PHONY: silent
