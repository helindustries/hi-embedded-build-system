%_tb.prj: %.prj $(TARGET_DEPS)
	cat "$<" > "$@"
	echo "vhdl work $*_tb.vhd" >> "$@"

%.exe: %.vhd %.prj $(ROMS) $(FPGA_TARGET).vhd $(TARGET_DEPS)
	$(WINE) $(FUSE) $(FUSE_OPTS) -o "$@" -prj "$*.prj" "work.$*"
	$(call cleanup,"fuse.log","fuse.xmsgs","isim.cmd" "fuseRelaunch.cmd" "_xmsgs")

%.wdb: %.exe $(TARGET_DEPS)
	@#$(WINE) $(ISIMGUI) -gui -exe "isim/$<.sim/$<" -intstyle $(INTSTYLE) -tclbatch $*_isim.tcl -wdb "$@"
	$(WINE) "$<" -gui -intstyle $(INTSTYLE) -tclbatch $*_isim.tcl -wdb "$@"
	$(call cleanup,"isim.log",,"_xmsgs")

isim: $(FPGA_TARGET)_tb.wdb $(FPGA_TARGET_DEPS)

clean-isim:
	rm -f "$(FPGA_TARGET)_tb.prj" "$(FPGA_TARGET)_tb.exe" "$(FPGA_TARGET)_tb.wdb" "xilinxsim.ini"
	rm -f "$(FPGA_TARGET)_tb_beh.prj" "$(FPGA_TARGET)_tb_isim_beh.exe" "$(FPGA_TARGET)_tb_isim_beh.wdb"
	rm -f "isim.log" "isim.cmd" "fuse.log" "fuse.xmsgs" "fuseRelaunch.cmd"
	rm -fr "isim"

.PHONY: isim clean-isim