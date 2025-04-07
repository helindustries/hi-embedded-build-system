export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

VERBOSE ?= 0
CFGMSG = printf "    %-30s %s\n"
ifneq "$(VERBOSE)" "1"
    V = @
    MSG = printf "  %-9s    %-20s  %s\n"
    FMSG = /usr/bin/true
    VMSG = /usr/bin/true
    VCFGMSG = /usr/bin/true
else
    MSG = /usr/bin/true
    FMSG = printf "%s\n"
    VMSG = printf "%s\n"
    VCFGMSG = printf "  %-9s %s\n"
endif

ifeq ($(strip $(shell uname -s)),Darwin)
    PLATFORM = MacOS
    # XXX: Add app package support once we move to a functional sim
    #PLATFORM_EXEC_OPEN = open
    #PLATFORM_EXEC_EXT = .app
    PLATFORM_EXEC_OPEN =
    PLATFORM_EXEC_EXT =
else
ifeq ($(strip $(shell uname -s)),Linux)
    PLATFORM = Linux
    PLATFORM_EXEC_OPEN =
    PLATFORM_EXEC_EXT =
else
    PLATFORM = Windows
    PLATFORM_EXEC_OPEN =
    PLATFORM_EXEC_EXT = .exe
endif
endif

PLATFORM_ID = $(shell echo "$(PLATFORM)" | tr '[:upper:]' '[:lower:]')
CPU_BASE_TARGET ?= $(CPU_TARGET)
HAS_UPLOAD_TARGET := $(filter upload upload-% %-upload %upload% install install-% %-install %install%,$(MAKECMDGOALS))

silent:
	@:

.PHONY: silent
