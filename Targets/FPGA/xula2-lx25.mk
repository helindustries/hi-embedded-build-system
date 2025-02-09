FPGA_DEVICE := xc6slx25-ftg256-2
FPGA_CONSTRAINTS ?= $(FPGA_BOARD).ucf

#XULALIB_PATH ?= $(EMBEDDED_HOME)/XuLA2/Projects/XuLALib
FPGA_PROJECT_ARGS += -i xess:$(XULALIB_PATH)
FPGA_PROJECT_ARGS += -s $(XULALIB_PATH)/Board_Packages/XuLA2.vhd

include $(MAKE_INC_PATH)/Targets/FPGA/Base/XULA.mk

upload_xula2-lx25: upload_xula

upload_xula2-lx25_jtag: upload_xilinx_jtag

.PHONY: upload_xula2-lx25 upload_xula2-lx25_jtag