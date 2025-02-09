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
else
ifeq ($(strip $(shell uname -s)),Linux)
	PLATFORM = Linux
else
	PLATFORM = Windows
endif
endif

silent:
	@:

.PHONY: silent
