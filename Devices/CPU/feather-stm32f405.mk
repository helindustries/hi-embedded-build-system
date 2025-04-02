CPU_SPEED = 168

USB = no
USB_VENDOR ?= Adafruit
USB_PRODUCT ?= Feather\ F405
USB_VID = 0x0483
USB_PID = 0x5740
USB_PROG_PID = 0x5740

CPU = stm32f405
STM32_SERIES = STM32F4xx
CPUARCH = cortex-m4
CPPFLAGS += -DHAL_PCD_MODULE_ENABLED -DUSBD_USE_CDC -DHAL_UART_MODULE_ENABLED -DARM_MATH_CM4F
CPPFLAGS += -DSTM32F405xx -DADAFRUIT_FEATHER_STM32F405 -DARDUINO_FEATHER_F405 "-DVARIANT_H=\"variant_FEATHER_F405.h\""
CPPFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
ASMFLAGS += -mabi=aapcs
LDFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
# If we want to use math functions on STM32, we need to manually compile the DSP lib into a module instead
#LIBS += arm_cortexM4lf_math

USB = yes
USB_VENDOR ?= Adafruit
USB_PRODUCT ?= Feather\ F405
USB_VID = 0x0483
USB_PID = 0x5740
USB_PROG_PID = 0x5740

CPU_DEVICE_RATE = 57600

include $(MAKE_INC_PATH)/Devices/CPU/Base/STM32.mk

upload_feather-stm32f405: upload_stm32

upload_feather-stm32f405_jtag: upload_arm_jtag

.PHONY: upload_feather-stm32f405 upload_feather-stm32f405_jtag
