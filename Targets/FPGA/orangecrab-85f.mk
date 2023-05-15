FPGA_VENDOR_ID := 1209
FPGA_PRODUCT_ID := 5af0
FPGA_DEVICE_SIZE := 85
FPGA_DEVICE_ID := 8mg285c
FPGA_PACKAGE := CSFBGA285
FPGA_SPEED := 8
FPGA_ENV ?=

include $(MAKE_INC_PATH)/Targets/FPGA/orangecrabbase.mk

upload_orangecrab-85f: upload_orangecrab

upload_orangecrab-85f_jtag: upload_jtag_lattice

.PHONY: upload_orangecrab-85f upload_orangecrab-85f_jtag
