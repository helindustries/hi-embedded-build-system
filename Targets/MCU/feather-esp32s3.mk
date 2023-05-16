# 240, 160, 80, 40, 20, 10, 5, 2
CPU_SPEED = 240
# 80, 40, 20, 10, 5, 2
BUS_SPEED = 80

MCU = esp32s3
CPU_CPPFLAGS =
CPU_LDFLAGS =
USB_NAME = Espressif
USB_VID = 0x303a
USB_PID = 0x1001
MCU_BOARD_RATE = 921600

ESP_FLASH_MODE ?= dio
ESP_FLASH_FREQ ?= 80m
ESP_FLASH_SIZE ?= 4MB
ESP_ELF_SHA256_OFFSET ?= 0xb0

include $(MAKE_INC_PATH)/Targets/MCU/esp32base.mk

upload_feather-esp32s3: upload_esp32s3

upload_feather-esp32s3_jtag: upload_esp32s3_jtag

.PHONY: upload_feather-esp32s3 upload_esp32s3_jtag
