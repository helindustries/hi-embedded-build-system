# 64, 48, 24, No USB 16, 8, 4, 2
CPU_SPEED = 64

CPU = nRF52840
CPUARCH = cortex-m4
CPPFLAGS += -DUSE_TINYUSB -DNRF52840_XXAA -DADAFRUIT_FEATHER_NRF52840 -DARDUINO_NRF52840_FEATHER -DARM_MATH_CM4F
CPPFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
ASMFLAGS += -mabi=aapcs
LDFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
LIBS += arm_cortexM4lf_math
ARM_LD = nrf52840_s140_v6.ld

USB = yes
USB_VENDOR ?= Adafruit
USB_PRODUCT ?= Feather\ NRF52840
USB_VID = 0x239a
USB_PID = 0x8029
USB_PROG_PID = 0x0029

CPU_DEVICE_RATE = 57600
NRF52_DEV_TYPE = 0x0052
NRF52_SD_SEQ = 0x00B6
NRF52_TOUCH_ARG = --touch 1200

include $(MAKE_INC_PATH)/Devices/CPU/Base/nRF52.mk

upload_feather-nrf52840: upload_nrf52

upload_feather-nrf52840_jtag: upload_arm_jtag

.PHONY: upload_feather-nrf52840 upload_feather-nrf52840_jtag
