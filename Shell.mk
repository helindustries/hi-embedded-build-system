SHELLCHECK := $(shell which shellcheck)
SHELL_BUILD_TARGETS := $(patsubst %.sh,%.sh.build.target,$(SHELL_FILES))

SHELLCHECK_OPTS ?= -f gcc -a -x -Cnever

build-shell: $(SHELL_BUILD_TARGETS) | silent

cfg-shell:
	@$(MSG) "[CFG]" "Shell"
	@$(CFGMSG) "SHELL_FILES:" "$(SHELL_FILES)"

%.sh.build.target: %.sh
	@$(MSG) "[SH]" "$<"
	$(V)$(SHELLCHECK) $(SHELLCHECK_OPTS) $(SHELLCHECK_INCLUDE_PATHS:%=-P "%") $(abspath "$<")

.PHONY: %.sh.build.target %.sh.test.target build-python test-python cfg-py
