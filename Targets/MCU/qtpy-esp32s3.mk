# 240, 160, 80, 40, 20, 10, 5, 2
CPU_SPEED = 240
# 80, 40, 20, 10, 5, 2
BUS_SPEED = 80

MCU = esp32s3

USB = nodefine
USB_VENDOR ?= Espressif
USB_PRODUCT ?= Feather\ ESP32S3
USB_VID = 0x303a
USB_PID = 0x1001

ESP_FLASH_MODE ?= dio
ESP_FLASH_FREQ ?= 80m
ESP_ELF_SHA256_OFFSET ?= 0xb0

# There are two variants and because of the missing QSPI port no need to disable PSRAM,
# so assume the ESP_WITH_PSRAM switch tells us, which variant we are dealing with.
ifeq ($(strip $(ESP_WITH_PSRAM)),)
    ESP_FLASH_SIZE ?= 4MB
else
    ESP_FLASH_SIZE ?= 8MB
endif

MCU_BOARD_RATE = 921600

include $(MAKE_INC_PATH)/Targets/MCU/Base/ESP32.mk

upload_qtpy-esp32s3: upload_esp32s3

upload_qtpy-esp32s3_jtag: upload_esp32s3_jtag

.PHONY: upload_feather-esp32s3 upload_esp32s3_jtag
