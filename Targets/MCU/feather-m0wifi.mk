# 48, 24, No USB 16, 8, 4, 2
CPU_SPEED = 48
# 24, 16, 8, 4, 2
BUS_SPEED = 24

MCU = samd21g18a
CPUARCH = cortex-m0plus
CPU_CPPFLAGS =
CPU_LDFLAGS = -larm_cortexM0l_math
USB_NAME = "Adafruit_Feather_M0"
USB_PID = 0x800b
USB_PROG_ID = 0x000b
USB_VID = 0x239a
MCU_BOARD_RATE = 57600

CORE_PLATFORM = SAMD
CORE_PATH = $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/adafruit/hardware/samd/"*"/cores/arduino" | sort | tail -n 1))
CORE_LIB_PATH = $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/adafruit/hardware/samd/"*"/libraries" | sort | tail -n 1))

include $(MAKE_INC_PATH)/Platforms/ARM/Toolchain.mk
include $(MAKE_INC_PATH)/Platforms/ARM/Targets.mk

upload_feather-m0wifi: upload_samd

upload_feather-m0wifi_jtag: upload_arm_jtag

#/Users/pschulze/Library/Arduino15/packages/adafruit/tools/arm-none-eabi-gcc/9-2019q4/bin/arm-none-eabi-g++ -mcpu=cortex-m0plus -mthumb -c -g -Os -Werror=return-type -std=gnu++11 -ffunction-sections -fdata-sections -fno-threadsafe-statics -nostdlib --param max-inline-insns-single=500 -fno-rtti -fno-exceptions -MMD "-D__SKETCH_NAME__=\"\"\"sketch_may14a.ino\"\"\"" -DF_CPU=48000000L -DARDUINO=10812 -DARDUINO_SAMD_ZERO -DARDUINO_ARCH_SAMD -DARDUINO_SAMD_ADAFRUIT -D__SAMD21G18A__ -DADAFRUIT_FEATHER_M0 -DARDUINO_SAMD_ZERO -DARM_MATH_CM0PLUS -DUSB_VID=0x239A -DUSB_PID=0x800B -DUSBCON -DUSB_CONFIG_POWER=100 "-DUSB_MANUFACTURER=\"Adafruit\"" "-DUSB_PRODUCT=\"Feather M0\"" -g -I/Users/pschulze/Library/Arduino15/packages/adafruit/hardware/samd/1.7.11/libraries/Adafruit_TinyUSB_Arduino/src/arduino -g -Os -D__SAMD21G18A__ -DADAFRUIT_FEATHER_M0 -DARDUINO_SAMD_ZERO -DARM_MATH_CM0PLUS -DUSB_VID=0x239A -DUSB_PID=0x800B -DUSBCON -DUSB_CONFIG_POWER=100 "-DUSB_MANUFACTURER=\"Adafruit\"" "-DUSB_PRODUCT=\"Feather M0\"" -g -I/Users/pschulze/Library/Arduino15/packages/adafruit/hardware/samd/1.7.11/libraries/Adafruit_TinyUSB_Arduino/src/arduino -I/Users/pschulze/Library/Arduino15/packages/adafruit/tools/CMSIS/5.4.0/CMSIS/Core/Include/ -I/Users/pschulze/Library/Arduino15/packages/adafruit/tools/CMSIS/5.4.0/CMSIS/DSP/Include/ -I/Users/pschulze/Library/Arduino15/packages/adafruit/tools/CMSIS-Atmel/1.2.2/CMSIS/Device/ATMEL/ -I/Users/pschulze/Library/Arduino15/packages/adafruit/hardware/samd/1.7.11/cores/arduino -I/Users/pschulze/Library/Arduino15/packages/adafruit/hardware/samd/1.7.11/variants/feather_m0 /var/folders/xt/clnjmtv50d7flyj_n1309wt80000gn/T/arduino_build_29876/sketch/sketch_may14a.ino.cpp -o /var/folders/xt/clnjmtv50d7flyj_n1309wt80000gn/T/arduino_build_29876/sketch/sketch_may14a.ino.cpp.o
#/Users/pschulze/Library/Arduino15/packages/adafruit/tools/arm-none-eabi-gcc/9-2019q4/bin/arm-none-eabi-g++ -L/var/folders/xt/clnjmtv50d7flyj_n1309wt80000gn/T/arduino_build_29876 -Os -Wl,--gc-sections -save-temps -T/Users/pschulze/Library/Arduino15/packages/adafruit/hardware/samd/1.7.11/variants/feather_m0/linker_scripts/gcc/flash_with_bootloader.ld -Wl,-Map,/var/folders/xt/clnjmtv50d7flyj_n1309wt80000gn/T/arduino_build_29876/sketch_may14a.ino.map --specs=nano.specs --specs=nosys.specs -mcpu=cortex-m0plus -mthumb -Wl,--cref -Wl,--check-sections -Wl,--gc-sections -Wl,--unresolved-symbols=report-all -Wl,--warn-common -Wl,--warn-section-align -o /var/folders/xt/clnjmtv50d7flyj_n1309wt80000gn/T/arduino_build_29876/sketch_may14a.ino.elf /var/folders/xt/clnjmtv50d7flyj_n1309wt80000gn/T/arduino_build_29876/sketch/sketch_may14a.ino.cpp.o /var/folders/xt/clnjmtv50d7flyj_n1309wt80000gn/T/arduino_build_29876/core/variant.cpp.o -Wl,--start-group -L/Users/pschulze/Library/Arduino15/packages/adafruit/tools/CMSIS/5.4.0/CMSIS/Lib/GCC/ -larm_cortexM0l_math -L/Users/pschulze/Library/Arduino15/packages/adafruit/hardware/samd/1.7.11/variants/feather_m0 -lm /var/folders/xt/clnjmtv50d7flyj_n1309wt80000gn/T/arduino_build_29876/../arduino_cache_792186/core/core_35a3833c8ad3fea86ab1b2e45bc4710d.a -Wl,--end-group
#/Users/pschulze/Library/Arduino15/packages/adafruit/tools/arm-none-eabi-gcc/9-2019q4/bin/arm-none-eabi-objcopy -O binary /var/folders/xt/clnjmtv50d7flyj_n1309wt80000gn/T/arduino_build_29876/sketch_may14a.ino.elf /var/folders/xt/clnjmtv50d7flyj_n1309wt80000gn/T/arduino_build_29876/sketch_may14a.ino.bin
#/Users/pschulze/Library/Arduino15/packages/adafruit/tools/arm-none-eabi-gcc/9-2019q4/bin/arm-none-eabi-objcopy -O ihex -R .eeprom /var/folders/xt/clnjmtv50d7flyj_n1309wt80000gn/T/arduino_build_29876/sketch_may14a.ino.elf /var/folders/xt/clnjmtv50d7flyj_n1309wt80000gn/T/arduino_build_29876/sketch_may14a.ino.hex
#/Users/pschulze/Library/Arduino15/packages/adafruit/tools/bossac/1.8.0-48-gb176eee/bossac -i -d --port=cu.usbserial-21240 -U -i --offset=0x2000 -w -v /var/folders/xt/clnjmtv50d7flyj_n1309wt80000gn/T/arduino_build_29876/sketch_may14a.ino.bin -R
