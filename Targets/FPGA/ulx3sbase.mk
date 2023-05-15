FPGA_BOARD_BASE := ulx3s
FPGA_FAMILY := ecp5u

include $(MAKE_INC_PATH)/Targets/FPGA/ecp5base.mk

upload_ulx3s: upload_fujprog

.PHONY: upload_ulx3s
