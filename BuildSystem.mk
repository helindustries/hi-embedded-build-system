MAKE_BASE_PATH := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))
MAKE_INC_PATH := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
STARTUP_MAKEFILE := $(abspath $(firstword $(MAKEFILE_LIST)))
include $(MAKE_INC_PATH)/Common.mk
include $(MAKE_INC_PATH)/PlatformUtils/PlatformUtils.mk

ifneq ($(call exists,"$(MAKE_INC_PATH)/Config.mk"),)
    include $(MAKE_INC_PATH)/Config.mk
endif

include $(MAKE_INC_PATH)/Toolchain.mk
