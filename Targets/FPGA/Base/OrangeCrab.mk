FPGA_BOARD_BASE := orangecrab
FPGA_FAMILY := ecp5u

include $(MAKE_INC_PATH)/Targets/FPGA/Base/ECP5U.mk

upload_orangecrab: upload_dfuutil

.PHONY: upload_orangecrab
