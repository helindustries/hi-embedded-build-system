FPGA_BOARD_BASE := orangecrab
FPGA_FAMILY := ecp5u

include $(MAKE_INC_PATH)/Targets/FPGA/ecp5base.mk

upload_orangecrab: upload_dfuutil

.PHONY: upload_orangecrab
