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

# Python is an essential part of this build system, figure things out here!
ifeq ($(strip $(PYTHON_ADDITIONAL_PATHS)),)
	# In this case we can just optionally set the variable, PYTHONPATH is exported
    PYTHON ?= $(shell $(WHICH) python)
else
    PYTHON_PATH := $(strip $(call shell-list,$(PYTHON_ADDITIONAL_PATHS)))

    ifeq ($(strip $(PYTHONPATH)),)
        PYTHON_ENV += PYTHONPATH="$(PYTHON_PATH)"
    else
        PYTHON_ENV += PYTHONPATH="$(PYTHONPATH):$(PYTHON_PATH)"
    endif

    ifeq ($(strip $(PYTHON)),)
	    # Further up we use the version of Python in PATH, here we get the specific path
	    PYTHON := $(PYTHON_ENV) "$(shell $(WHICH) python)"
    else
	    PYTHON := $(PYTHON_ENV) "$(PYTHON)"
    endif
endif

silent:
	@:

.PHONY: silent
