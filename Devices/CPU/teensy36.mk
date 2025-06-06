# 240, 228, 216, 204, 192, 180, 168, 156, 144,
# 132, 120, 96, 72, 48, 24, No USB 16, 8, 4, 2
CPU_SPEED ?= 180
# 60, 56, 48, 36, 24, 16, 8, 4, 2
BUS_SPEED ?= 60

CPU = mk66fx1m0
CPUARCH = cortex-m4
CPPFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
LDFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
LIBS += arm_cortexM4lf_math
USB_ID = "Teensy\s3.6"

include $(MAKE_INC_PATH)/Devices/CPU/Base/Teensy.mk

upload_teensy36: upload_teensy

upload_teensy36_jtag: upload_arm_jtag

.PHONY: upload_teensy36 upload_teensy36_jtag
