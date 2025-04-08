$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
ifeq ($(strip $(VERBOSE)),1)
	@$(VMSG) "Building Subtarget $(patsubst %/,%,$@)"
	@$(VCFGMSG) 'NAME:' '$(patsubst %/,%,$@)'
	@$(VCFGMSG) 'BUILD_DIR:' '$(BUILD_DIR)'
	@$(VCFGMSG) 'MAKEFLAGS:' '$(MAKEFLAGS)'
	@$(VCFGMSG) 'MAKECMDGOALS:' '$(MAKECMDGOALS)'
else
	@$(MSG) "[MAKE]" "$(patsubst %/,%,$@)"
endif
	$(V)$(MAKE) --directory='$(abspath $@)' --file='$(abspath $@)/Makefile' $(MAKEFLAGS) 'BUILD_DIR=$(BUILD_DIR)/$(patsubst %/,%,$@)' $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)
