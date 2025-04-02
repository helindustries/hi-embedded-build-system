FPGA_DEVICE_BASE := ulx3s
FPGA_FAMILY := ecp5u

include $(MAKE_INC_PATH)/Devices/FPGA/Base/ECP5U.mk

upload_ulx3s: upload_fujprog

.PHONY: upload_ulx3s
