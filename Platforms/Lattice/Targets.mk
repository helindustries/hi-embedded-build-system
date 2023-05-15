FPGA_DEVICE_FULL := $(FPGA_DEVICE)-$(FPGA_DEVICE_ID)
FPGA_FAMILY_UPPER := $(shell echo "$(FPGA_FAMILY)" | tr '[:lower:]' '[:upper:]')
FPGA_DEVICE_UPPER := $(shell echo "$(FPGA_DEVICE)" | tr '[:lower:]' '[:upper:]')
FPGA_DEVICE_FULL_UPPER := $(shell echo "$(FPGA_DEVICE_FULL)" | tr '[:lower:]' '[:upper:]')
LATTICE_BUILD_DIR ?= $(BUILD_DIR)/lattice

define cleanup #,reports,reports_mr,temporaries
    $(V)if [ ! -z '$(1)' ]; then                      \
        mkdir -p "reports";                           \
        cp -f $(1) "reports" >/dev/null 2>&1 || true; \
    fi

    $(V)if [ ! -z '$(1)$(2)$(3)' ]; then \
        rm -fr $(1) $(2) $(3) || true;   \
    fi
endef

%.ngd: %.vhd %.lpt %.ldc $(FPGA_TARGET_DEPS)
	@$(MSG) "[NGD]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	@$(FMSG) "INFO:Synthesizing $*.vhd"
	$(V)mkdir -p "$(LATTICE_BUILD_DIR)" "reports"
	$(V)echo '-a "$(FPGA_FAMILY_UPPER)"\n-d $(FPGA_DEVICE_UPPER)\n-t $(FPGA_PACKAGE)\n-s $(FPGA_SPEED)' > "$(LATTICE_BUILD_DIR)/$*.synproj"
	$(V)cat "$*.lpt" >> "$(LATTICE_BUILD_DIR)/$*.synproj"
	$(V)$(MAKEFPGAPRJ) "$<" --lattice -l "work" $(FPGA_PROJECT_ARGS) >> "$(LATTICE_BUILD_DIR)/$*.synproj"
	$(V)echo '-top $*\n\n' >> "$(LATTICE_BUILD_DIR)/$*.synproj"
	$(V)echo '-p "C:/lscc/diamond/3.12/ispfpga/sa5p00/data"\n' >> "$(LATTICE_BUILD_DIR)/$*.synproj"
	$(V)echo '-sdc "$*.ldc"\n' >> "$(LATTICE_BUILD_DIR)/$*.synproj"
	$(V)echo '-ngd "$@"\n' >> "$(LATTICE_BUILD_DIR)/$*.synproj"
	$(V)$(LATTICE_WINE) $(LATTICE_SYNTHESIS) $(LATTICE_SYNTHESIS_OPTS) -f "$(LATTICE_BUILD_DIR)/$*.synproj" $(PROCESS_OUTPUT)
	$(V)$(call cleanup,"synthesis.log" "$*_drc.log" "$*.arearep","$*.lsedata" "$*_lse.twr" "$*_prim.v" "xxx_lse_sign_file" "xxx_lse_cp_file_list" "_ngo" ".vdbs")

%_map.ncd: %.ngd %.$(FPGA_CONSTRAINTS) $(FPGA_TARGET_DEPS)
	@$(MSG) "[MAPNCD]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)$(LATTICE_WINE) $(LATTICE_MAP) $(LATTICE_SYNTHESIS_OPTS) -a "$(FPGA_FAMILY_UPPER)" -p "$(FPGA_DEVICE_UPPER)" -t "$(FPGA_PACKAGE)" -s $(FPGA_SPEED) -oc Commercial "$<" -o "$@" -pr "$*.prf" -mp "reports/$*.mrp" -lpf "$(abspath $*.$(FPGA_CONSTRAINTS))" $(PROCESS_OUTPUT)
	$(V)$(call cleanup,"$*_map.hrr","$*_map.cam" "$*_map.asd")

%.ncd: %_map.ncd %.pt %.p2t %.p3t %.$(FPGA_CONSTRAINTS) $(FPGA_TARGET_DEPS)
	@$(MSG) "[NCD]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)cp "$*.p3t" "$*.p2t" "$*.pt" "$(LATTICE_BUILD_DIR)/"
	$(V)echo "-log "reports/$*.log"\n-o "reports/$*.csv"\n-pr "$*.prf"" >> "$(LATTICE_BUILD_DIR)/$*.p3t"
	$(V)$(LATTICE_WINE) $(LATTICE_MPARTRCE) $(LATTICE_SYNTHESIS_OPTS) -p "$*.p2t" -f "$(LATTICE_BUILD_DIR)/$*.p3t" -tf "$*.pt" "$<" "$@" $(PROCESS_OUTPUT)
	$(V)$(LATTICE_WINE) $(LATTICE_TRCE) $(LATTICE_SYNTHESIS_OPTS) -f "$*.pt" -o "reports/$*.twr" "$@" "$*.prf" $(PROCESS_OUTPUT)
	$(V)$(call cleanup,"$*.par" "$*.pad","$*_trce.asd" "$*.dir")

%.$(FPGA_BOARD).bit: %.ncd %.t2b %.$(FPGA_CONSTRAINTS) $(FPGA_TARGET_DEPS)
	@$(MSG) "[BIT]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	@$(FMSG) "INFO:Generating $@"
	$(V)$(LATTICE_WINE) $(LATTICE_BITGEN) $(LATTICE_SYNTHESIS_OPTS) -w "$<" -f "$*.t2b" -e -s "$*.sec" -k "$*.bek" "$*.prf" $(PROCESS_OUTPUT)
	$(V)mv "$*.bit" "$@"
	$(V)$(call cleanup,"$*.bgn","$*.alt" "$*.drc")

synthesize_lattice: layout_lattice $(FPGA_TARGET_DEPS)

layout_lattice: $(FPGA_TARGET).ngd $(FPGA_TARGET_DEPS)

%.bit.lattice.svf: %.bit $(FPGA_TARGET_DEPS)
	@$(MSG) "[SVF]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)$(LATTICE_WINE) $(LATTICE_DDTCMD) -oft -svfsingle -if "$<" -dev $(FPGA_DEVICE_UPPER) -op "Fast Program" -reset -of "$@" $(PROCESS_OUTPUT)

$(FPGA_DEPLOY_TARGET).upload_jtag_lattice.timestamp: $(FPGA_DEPLOY_TARGET).lattice.svf $(FPGA_TARGET_DEPS)
ifneq ($(strip $(NO_GATEWARE_UPLOAD)),yes)
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)"$(OPENOCD)" $(OPENOCD_DEBUG) -s "$(OPENOCD_CFG_DIR)" -f "$(OPENOCD_CFG_DIR)/$(FPGA_DEBUG_ADAPTER).cfg" -f "$(MAKE_INC_PATH)/Targets/FPGA/$(FPGA_BOARD).ocd.cfg" -c "init" -c "scan_chain" -c "svf $< -ignore_error" -c "shutdown" $(PROCESS_OUTPUT)
	$(V)touch "$@"
endif

upload_jtag_lattice: $(FPGA_DEPLOY_TARGET).upload_jtag_lattice.timestamp

clean_lattice: clean-modelsim
	$(V)rm -f "$(FPGA_TARGET).prf" "$(FPGA_TARGET).synproj" "$(FPGA_TARGET).ldf" "$(FPGA_TARGET).ngd" "$(FPGA_TARGET)_map.ncd" "$(FPGA_TARGET).ncd" "$(FPGA_TARGET).$(FPGA_BOARD).bit" "$(FPGA_TARGET).$(FPGA_BOARD).bit.lattice.svf" "$(FPGA_TARGET).wcfg"
	$(V)rm -f ".run_manager.ini"
	$(V)rm -fr "$(LATTICE_BUILD_DIR)" "reports"

.PHONY: synthesize_lattice layout_lattice clean_lattice
