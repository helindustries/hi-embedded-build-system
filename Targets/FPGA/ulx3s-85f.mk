FPGA_DEVICE_SIZE := 85
FPGA_DEVICE_ID := 6bg381c
FPGA_PACKAGE := CABGA381
FPGA_SPEED := 6
FPGA_ENV ?=

FPGA_FLASH_CHIP := is25lp128f     # chip: is25lp032d is25lp128f s25fl164k
FPGA_FLASH_SPI := 4               # config flash: 1:SPI (standard), 4:QSPI (quad)
FPGA_FLASH_READ_MHZ := 62.0       # 2.4 4.8 9.7 19.4 38.8 62.0
FPGA_FLASH_READ_MODE := fast-read # fast-read dual-spi qspi

include $(MAKE_INC_PATH)/Targets/FPGA/ulx3sbase.mk

upload_ulx3s-85f: upload_ulx3s

upload_ulx3s-85f_jtag: upload_jtag_lattice

.PHONY: upload_ulx3s-85f upload_ulx3s-85f_jtag
