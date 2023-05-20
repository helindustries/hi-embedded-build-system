# 120, 96, 72, 48, 24, No USB 16, 8, 4, 2
CPU_SPEED = 96
# 40, 36, 24, 16, 8, 4, 2
BUS_SPEED = 48

MCU = mk20dx256
CPUARCH = cortex-m4
USB_ID = "Teensy\s3.2"

include $(MAKE_INC_PATH)/Targets/MCU/teensybase.mk

upload_teensy32: upload_teensy

.PHONY: upload_teensy32
