all: teensy_loader_cli dependencies build-python build-shell

install: teensy_loader_cli dependencies build-python build-shell

test: dependencies test-python

clean: clean-teensy_loader_cli clean-dependencies

cfg: dependencies cfg-python cfg-shell

.PHONY: all install test clean cfg

BUILD_DIR ?= Build
PYTHON_FILES := $(wildcard *.py */*.py)
SHELL_FILES := $(wildcard *.sh */*.sh)
DEPENDENCIES := Make:Resetter:Resetter

include ../BuildSystem.mk
include $(MAKE_INC_PATH)/Python.mk
include $(MAKE_INC_PATH)/Shell.mk
include $(MAKE_INC_PATH)/Dependencies.mk

ifeq ($(shell uname -s),Darwin)
	OS=MACOSX
else
	ifeq ($(shell uname -s),Linux)
		OS=LINUX
	else
		OS=WINDOWS
	endif
endif

teensy_loader_cli:
	@$(MSG) "[MAKE]" "Teensy Loader CLI"
	$(V)$(call process_output,$(MAKE) -C $(MAKE_BASE_PATH)/TeensyLoader 'USE_LIBUSB=no' 'OS=$(OS)')

clean-teensy_loader_cli:
	@$(MSG) "[MAKE]" "Teensy Loader CLI"
	$(V)$(call process_output,$(MAKE) -C $(MAKE_BASE_PATH)/TeensyLoader clean)
