# 48, 24, No USB 16, 8, 4, 2
CPU_SPEED = 48
# 24, 16, 8, 4, 2
BUS_SPEED = 24

MCU = mkl26z64
CPUARCH = cortex-m0plus
LIBS += arm_cortexM0l_math
SERIAL_ID = "Teensy\sLC"
MCU_BOARD_RATE = 57600

include $(MAKE_INC_PATH)/Targets/MCU/Base/Teensy.mk

upload_teensylc: upload_teensy

.PHONY: upload_teensylc
