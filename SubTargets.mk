$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	@$(VMSG) "Building Subtarget $(patsubst %/,%,$@)"
	@$(VCFGMSG) 'NAME:' '$(patsubst %/,%,$@)'
	@$(VCFGMSG) 'BUILD_DIR:' '$(BUILD_DIR)'
	$(V)$(MAKE) --directory='$(abspath $@)' --file='$(abspath $@)/Makefile' $(MAKEFLAGS) 'BUILD_DIR=$(BUILD_DIR)/$(patsubst %/,%,$@)' $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)
