FPGA_DEVICE_BASE := orangecrab
FPGA_FAMILY := ecp5u

include $(MAKE_INC_PATH)/Devices/FPGA/Base/ECP5U.mk

upload_orangecrab: upload_dfuutil

.PHONY: upload_orangecrab
