export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

VERBOSE ?= 0
CFGMSG = printf "    %-30s %s\n"
ifneq "$(VERBOSE)" "1"
	V = @
	MSG = printf "  %-8s    %-20s  %s\n"
	FMSG = /usr/bin/true
	VMSG = /usr/bin/true
	VCFGMSG = /usr/bin/true
else
	MSG = /usr/bin/true
	FMSG = printf "%s\n"
	VMSG = printf "%s\n"
	VCFGMSG = printf "  %-8s %s\n"
endif

silent:
	@:

.PHONY: silent
