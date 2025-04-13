$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
ifeq ($(strip $(VERBOSE)),1)
	@$(VMSG) "Building Subtarget $(patsubst %/,%,$@)"
	@$(VCFGMSG) 'NAME:' '$(patsubst %/,%,$@)'
	@$(VCFGMSG) 'IN_BUILD_DIR:' '$(IN_BUILD_DIR)'
	@$(VCFGMSG) 'MAKEFLAGS:' '$(MAKEFLAGS)'
	@$(VCFGMSG) 'MAKECMDGOALS:' '$(MAKECMDGOALS)'
else
	@$(MSG) "[MAKE]" "$(patsubst %/,%,$@)"
endif
	$(V)$(MAKE) --directory='$(abspath $@)' --file='$(abspath $@)/Makefile' $(MAKEFLAGS) 'IN_BUILD_DIR=$(IN_BUILD_DIR)/$(patsubst %/,%,$@)' $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)
