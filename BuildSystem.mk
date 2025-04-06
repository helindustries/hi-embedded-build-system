MAKE_BASE_PATH := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))
MAKE_INC_PATH := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
STARTUP_MAKEFILE := $(firstword $(MAKEFILE_LIST))
include $(MAKE_INC_PATH)/Common.mk

ifneq ($(strip $(shell ls --color=never "$(MAKE_INC_PATH)/Config.mk" 2>/dev/null)),)
include $(MAKE_INC_PATH)/Config.mk
endif

include $(MAKE_INC_PATH)/Toolchain.mk
