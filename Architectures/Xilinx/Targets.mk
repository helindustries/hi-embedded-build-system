cleanup = $(PYTHON) "$(MAKE_INC_PATH)/Tools/clean_fpga_reports.py" --reports $(1) --mrs $(2) --temps $(3)

%.lso:
	@$(MSG) "[LSO]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)$(call write,"work","$@")

%.prj: %.vhd $(FPGA_TARGET_DEPS)
	@$(MSG) "[PRJ]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)$(MAKEFPGAPRJ) "$<" --xilinx -l "work" -o "$@" -p $(FPGA_PROJECT_ARGS)

%.ngc: %.xst %.prj %.lso $(FPGA_ROMS) $(FPGA_TARGET_DEPS)
	@$(MSG) "[NGC]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	@$(FMSG) "INFO:Synthesizing $*.vhd"
	$(V)$(MKDIR) "reports" "xst/projnav.tmp"
	$(V)$(call process_output,$(XILINX_ISE_WINE) $(XILINX_ISE_XST) -intstyle $(INTSTYLE) -ifn "$*.xst" -ofn "reports/$*.syr")
	$(V)$(call cleanup,,$*_xst.xrpt,"_xmsgs" "xst" "webtalk.log" "xlnx_auto_0_xdb")

%.ngd: %.ngc %.$(FPGA_CONSTRAINTS) $(FPGA_TARGET_DEPS)
	@$(MSG) "[NGD]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	@$(FMSG) "INFO:Building $@"
	$(V)$(call process_output,$(XILINX_ISE_WINE) $(XILINX_ISE_NGDBUILD) -intstyle $(INTSTYLE) -dd _ngo -nt timestamp -uc "$*.$(FPGA_CONSTRAINTS)" $(NGDBUILD_ARGS) -p $(FPGA_DEVICE_ID) "$<" "$@")
	$(V)$(call cleanup,"$*.bld","$*_ngdbuild.xrpt","_ngo" "_xmsgs" "xlnx_auto_0_xdb" "webtalk.log")

%_map.ncd: %.ngd $(FPGA_TARGET_DEPS)
	@$(MSG) "[MAPNCD]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)$(call process_output,$(XILINX_ISE_WINE) $(XILINX_ISE_MAP) -intstyle $(INTSTYLE) -p $(FPGA_DEVICE_ID) -w -logic_opt off -ol high -t 1 -xt 0 -register_duplication off -r 4 -global_opt off -mt off -ir off -pr off -lc off -power off -o "$@" "$<" "$*.pcf")
	$(V)$(call cleanup,"$*_map.map" "$*_map.mrp","$*_usage.xml" "$*_summary.xml" "$*_map.xrpt","_xmsgs" "xlnx_auto_0_xdb" "webtalk.log")

%.ncd: %_map.ncd %.$(FPGA_CONSTRAINTS) $(FPGA_TARGET_DEPS)
	@$(MSG) "[NCD]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)$(call process_output,$(XILINX_ISE_WINE) $(XILINX_ISE_PAR) -w -intstyle $(INTSTYLE) -ol high -mt off "$<" "$@" "$*.pcf")
	$(V)$(call process_output,$(XILINX_ISE_WINE) $(XILINX_ISE_TRCE) -intstyle $(INTSTYLE) -v 3 -s 2 -n 3 -fastpaths -xml "$*.twx" "$@" -o "$*.twr" "$*.pcf" -ucf "$*.$(FPGA_CONSTRAINTS)")
	$(V)$(call cleanup,"$*_pad.txt" "$*.unroutes" "$*.twr" "$*.par","par_usage_statistics.html" "$*_par.xrpt" "$*.twx" "$*.ptwx" "$*.pad" "$*_pad.csv","_xmsgs" "$*.xpi" "webtalk.log" "xlnx_auto_0_xdb")

%.$(FPGA_DEVICE).bit: %.ncd %.ut $(FPGA_TARGET_DEPS)
	@$(MSG) "[BIT]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$@)"
	@$(FMSG) "INFO:Generating $@"
	$(V)$(call process_output,$(XILINX_ISE_WINE) $(XILINX_ISE_BITGEN) -intstyle $(INTSTYLE) -f $*.ut $<)
	$(V)$(MOVE) "$*.bit" "$@"
	$(V)$(call cleanup,"$*.bgn" "$*.drc" "$*.pcf","$*_usage.xml" "$*_summary.xml" "usage_statistics_webtalk.html","_xmsgs" "$*_bitgen.xwbt" "$*_map.ngm" "$*.ngr" "webtalk.log" "xlnx_auto_0_xdb")

synthesize_xilinx: $(FPGA_TARGET).ngc $(FPGA_TARGET_DEPS)

layout_xilinx: $(FPGA_TARGET).ngd $(FPGA_TARGET_DEPS)

clean_xilinx: clean-isim
	@$(MSG) "[CLEAN]" "$(FPGA_TARGET)" "Xilinx"
	$(V)$(RM) "$(FPGA_TARGET).bit" "$(FPGA_TARGET).ncd" "$(FPGA_TARGET)_map.ncd" "$(FPGA_TARGET)_map.ngm" "$(FPGA_TARGET).ngd"
	$(V)$(RM) "$(FPGA_TARGET).ngc" "$(FPGA_TARGET).ngr" "$(FPGA_TARGET).pcf" "$(FPGA_TARGET).deps"
	$(V)$(RM) "$(FPGA_TARGET).syr" "$(FPGA_TARGET).gise" "$(FPGA_TARGET).lso" "$(FPGA_TARGET)_summary.html"
	$(V)$(RMDIR) "iseconfig" "reports"


ifeq ($(strip $(FORCE_GATEWARE_UPLOAD)),yes)
XILINX_CREATE_TIMESTAMP =
upload_jtag_xilinx: $(FPGA_DEPLOY_TARGET).xilinx.svf $(FPGA_TARGET_DEPS)
else
XILINX_CREATE_TIMESTAMP = && touch "$@"
upload_jtag_xilinx: $(FPGA_DEPLOY_TARGET).upload_jtag_xilinx.timestamp

$(FPGA_DEPLOY_TARGET).upload_jtag_xilinx.timestamp: $(FPGA_DEPLOY_TARGET).xilinx.svf $(FPGA_TARGET_DEPS)
endif
ifneq ($(strip $(NO_GATEWARE_UPLOAD)),yes)
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(FPGA_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)$(call process_output,"$(OPENOCD)" $(OPENOCD_DEBUG) -s "$(OPENOCD_CFG_DIR)" -f "$(OPENOCD_CFG_DIR)/$(FPGA_DEBUG_ADAPTER).cfg" -f "$(MAKE_INC_PATH)/Devices/FPGA/$(FPGA_DEVICE).ocd.cfg" -c "init" -c "scan_chain" -c "svf $< -ignore_error" -c "shutdown") $(XILINX_CREATE_TIMESTAMP)
endif

upload_xilinx_jtag: $(FPGA_DEPLOY_TARGET).upload_jtag_xilinx.timestamp

.PHONY: synthesize_xilinx layout_xilinx clean_xilinx upload_xilinx_jtag
