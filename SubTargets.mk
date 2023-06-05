$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	@$(VMSG) "Building Subtarget $@"
	@$(VCFGMSG) 'NAME:' '$*'
	@$(VCFGMSG) 'BUILD_DIR:' '$(BUILD_DIR)'
	$(V)$(MAKE) --directory='$(abspath $@)' --file='$(abspath $@)/Makefile' 'BUILD_DIR=$(BUILD_DIR)/$@' 'VERBOSE=$(VERBOSE)' 'NO_GATEWARE_DEPS=$(NO_GATEWARE_DEPS)' 'NO_TOOLS_DEPS=$(NO_TOOLS_DEPS)' 'NO_TESTS_DEPS=$(NO_TESTS_DEPS)' $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)
