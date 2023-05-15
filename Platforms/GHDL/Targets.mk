GHDL_LIB_ARGS=$(shell "$(MAKEFPGAPRJ)" "$(FPGA_TARGET).vhd" --ghdl -l "work" $(FPGA_PROJECT_ARGS) | sed -E "s%([a-zA-Z0-9_\-]+)\ .*%-P$(GHDL_BUILD_DIR)/\1/%" | grep -v "^-P$(GHDL_BUILD_DIR)\/work" | sort | uniq)

$(GHDL_BUILD_DIR)/$(GHDL_WORK)/%.o: %.vhd $(ROMS) $(FPGA_TARGET).vhd $(FPGA_TARGET_DEPS)
	@$(MSG) "[SIM]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)$(MAKEFPGAPRJ) "$<" --ghdl -l "work" $(FPGA_PROJECT_ARGS) | \
		xargs -n 2 sh -c ' \
			echo "Analyzing $$2 ($$1)"; \
			mkdir -p "$(GHDL_BUILD_DIR)/$$1"; \
			"$(GHDL)" -a $(GHDL_ARGS) $(GHDL_LIB_ARGS) --work="$$1" --workdir="$(GHDL_BUILD_DIR)/$$1/" "$$2"' sh
	$(V)"$(GHDL)" -a $(GHDL_ARGS) $(GHDL_LIB_ARGS) --work=$(GHDL_WORK) --workdir="$(GHDL_BUILD_DIR)/$(GHDL_WORK)" "$<"

%_tb: $(GHDL_BUILD_DIR)/$(GHDL_WORK)/%_tb.o $(ROMS) $(FPGA_TARGET_DEPS)
	@$(MSG) "[TB]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(GHDL)" -e $(GHDL_ARGS) $(GHDL_LIB_ARGS) --work=$(GHDL_WORK) --workdir="$(GHDL_BUILD_DIR)/$(GHDL_WORK)" "$@"

%_tb.fst: %_tb $(FPGA_TARGET_DEPS)
	@$(MSG) "[FST]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(GHDL)" -r $(GHDL_ARGS) $(GHDL_LIB_ARGS) --work=$(GHDL_WORK) --workdir="$(GHDL_BUILD_DIR)/$(GHDL_WORK)" "$<" --stop-time=$(GHDL_TIMEOUT) --fst="$@"

%_tb.ghw: %_tb $(FPGA_TARGET_DEPS)
	@$(MSG) "[GHW]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(GHDL)" -r $(GHDL_ARGS) $(GHDL_LIB_ARGS) --work=$(GHDL_WORK) --workdir="$(GHDL_BUILD_DIR)/$(GHDL_WORK)" "$<" --stop-time=$(GHDL_TIMEOUT) --wave="$@"

ghdl: $(FPGA_TARGET)_tb.ghw $(FPGA_TARGET)_tb.tcl $(FPGA_TARGET_DEPS)
	# Requires Switch.pm (run "cpan install Switch")
	@$(MSG) "[SIM]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)$(GTKWAVE) -S "$(FPGA_TARGET)_tb.tcl" "$<"

clean-ghdl:
	$(V)"$(GHDL)" --clean
ifneq ($(strip $(GHDL_BUILD_DIR)),)
	$(V)rm -fr "$(GHDL_BUILD_DIR)"
endif
	$(V)rm -f "$(FPGA_TARGET)_tb.fst" "$(FPGA_TARGET)_tb.ghw" "$(FPGA_TARGET)_tb" "$(FPGA_TARGET)_tb.exe" "*.cf"

.PHONY: ghdl clean-ghdl
