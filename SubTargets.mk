$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	@$(VMSG) "Building Subtarget $(patsubst %/,%,$@)"
	@$(VCFGMSG) 'NAME:' '$(patsubst %/,%,$@)'
	@$(VCFGMSG) 'BUILD_DIR:' '$(BUILD_DIR)'
	$(V)$(MAKE) --directory='$(abspath $@)' --file='$(abspath $@)/Makefile' $(MAKEFLAGS) 'STARTUP_MAKEFILE=$(STARTUP_MAKEFILE)' 'BUILD_DIR=$(BUILD_DIR)/$@' \
					'VERBOSE=$(VERBOSE)' 'NO_GATEWARE_DEPS=$(NO_GATEWARE_DEPS)' 'NO_TOOLS_DEPS=$(NO_TOOLS_DEPS)' 'NO_TESTS_DEPS=$(NO_TESTS_DEPS)' \
					'CPU_BASE_TARGET=$(CPU_BASE_TARGET)' $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)
