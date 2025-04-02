# 64, 48, 24, No USB 16, 8, 4, 2
CPU_SPEED = 64

CPU = nRF52832
CPUARCH = cortex-m4
CPPFLAGS += -DNRF52832_XXAA -DADAFRUIT_FEATHER_NRF52832 -DARDUINO_NRF52832_FEATHER -DARM_MATH_CM4F
CPPFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
ASMFLAGS += -mabi=aapcs
LDFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
LIBS += arm_cortexM4lf_math
ARM_LD = nrf52832_s132_v6.ld

USB = yes
USB_VENDOR ?= Adafruit
USB_PRODUCT ?= Feather\ NRF52832
USB_VID = 0x10c4
USB_PID = 0xea60
USB_PROG_PID = 0xea60

CPU_DEVICE_RATE = 57600
NRF52_DEV_TYPE = 0x0052
NRF52_SD_SEQ = 0x00B7
#NRF52_TOUCH_ARG = --touch 1200

include $(MAKE_INC_PATH)/Devices/CPU/Base/nRF52.mk

upload_feather-nrf52832: upload_nrf52

upload_feather-nrf52832_jtag: upload_arm_jtag

.PHONY: upload_feather-nrf52832 upload_feather-nrf52832_jtag
