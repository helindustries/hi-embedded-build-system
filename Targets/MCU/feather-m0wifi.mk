# 48, 24, No USB 16, 8, 4, 2
CPU_SPEED = 48
# 24, 16, 8, 4, 2
BUS_SPEED = 24

MCU = samd21g18a
USB_NAME = "Adafruit_Feather_M0"
USB_VID = 0x239a
USB_PID = 0x800b
USB_PROG_ID = 0x000b
CPUARCH = cortex-m0plus
CPPFLAGS += -DARDUINO_SAMD_ADAFRUIT -DADAFRUIT_FEATHER_M0 -DARDUINO_SAMD_ZERO -DARM_MATH_CM0PLUS
CPPFLAGS += -DUSB_VID=$(USB_VID) -DUSB_PID=$(USB_PID) -DUSB_MANUFACTURER=\"Adafruit\" -DUSB_PRODUCT=\"Feather\ M0\"
CPPFLAGS += -DUSBCON -DUSB_CONFIG_POWER=100
LIBS += arm_cortexM0l_math
MCU_BOARD_RATE = 57600
SAMD_EXEC_OFFSET = 0x2000

include $(MAKE_INC_PATH)/Targets/MCU/samdbase.mk

upload_feather-m0wifi: upload_samd

upload_feather-m0wifi_jtag: upload_arm_jtag

.PHONY: upload_feather-m0wifi upload_feather-m0wifi_jtag
