CORE_PLATFORM := RPI
RPI_TOOLCHAIN_DIR ?= $(ARDUINO_USERPATH)/packages/rp2040
RPI_BASE_PATH ?= $(call latest,"$(RPI_TOOLCHAIN_DIR)/*/")
CORE_PATH ?= $(RPI_BASE_PATH)/cores/rp2040
CORE_LIB_PATH ?= $(RPI_BASE_PATH)/libraries
CORE_VARIANTS_PATH ?= $(RPI_BASE_PATH)/variants
ARM_COMPILERPATH ?= $(call latest,"$(RPI_TOOLCHAIN_DIR)/tools/pqt-gcc/*/")
ELF_MAP := $(CPU_TARGET).$(CPU_DEVICE).map
USE_DEFAULT_USB_SERIAL_DETECT := yes
RPI_UF2_UPLOAD_FAMILY := RP2040
CORE_SKIP_NEW_O := yes
ARM_USE_CMSIS := no

RPI_TOOLS_DIR := $(RPI_BASE_PATH)/tools
RPI_UF2CONV := $(RPI_TOOLS_DIR)/uf2conv.py
RPI_SIGNING := $(RPI_TOOLS_DIR)/signing.py
RPI_SIMPLESUB := $(RPI_TOOLS_DIR)/simplesub.py
RPI_PICOTOOL := $(call latest,"$(RPI_TOOLCHAIN_DIR)/tools/pqt-picotool/*/picotool")
RPI_SDK_PATH := $(RPI_BASE_PATH)/pico-sdk
RPI_SIGNING_PRIVATE_KEY := "$(abspath $(call path-dirname,'$(STARTUP_MAKEFILE))/private.key')"
ARM_LD_SOURCE ?= $(RPI_BASE_PATH)/lib/$(CPU)/memmap_default.ld
ARM_LD ?= $(BUILD_DIR)/$(call path-basename,"$(ARM_LD_SOURCE)")
BINARY_DEPS += $(ARM_LD)

include $(MAKE_INC_PATH)/Architectures/ARM/Toolchain.mk

CFLAGS += -std=gnu11
CPPFLAGS += -Werror=return-type -Wno-psabi
CPPFLAGS += -DARDUINO_ARCH_RP2040 -DLWIP_IPV6=0 -DLWIP_IPV4=1 -DLWIP_IGMP=1 -DLWIP_CHECKSUM_CTRL_PER_NETIF=1
CPPFLAGS += -DPICO_FLASH_SIZE_BYTES=8388608 -DFILE_COPY_CONSTRUCTOR_SELECT=FILE_COPY_CONSTRUCTOR_PUBLIC -DUSE_UTF8_LONG_NAMES=1
CPPFLAGS += -DDISABLE_FS_H_WARNING=1 -DCYW43_LWIP=1 -DCYW43_PIO_CLOCK_DIV_DYNAMIC=1 -DWIFICC=CYW43_COUNTRY_WORLDWIDE
CPPFLAGS += -DCFG_TUSB_MCU=OPT_MCU_RP2040 -DCFG_TUSB_OS=OPT_OS_PICO -DLIB_BOOT_STAGE2_HEADERS=1 -DLIB_PICO_BIT_OPS=1
CPPFLAGS += -DLIB_PICO_BIT_OPS_PICO=1 -DLIB_PICO_CLIB_INTERFACE=1 -DLIB_PICO_CRT0=1 -DLIB_PICO_CXX_OPTIONS=1 -DLIB_PICO_DIVIDER=1
CPPFLAGS += -DLIB_PICO_DIVIDER_COMPILER=1 -DLIB_PICO_DOUBLE=1 -DLIB_PICO_DOUBLE_PICO=1 -DLIB_PICO_FIX_RP2040_USB_DEVICE_ENUMERATION=1
CPPFLAGS += -DLIB_PICO_FLOAT=1 -DLIB_PICO_FLOAT_PICO=1 -DLIB_PICO_FLOAT_PICO_VFP=1 -DLIB_PICO_INT64_OPS=1 -DLIB_PICO_INT64_OPS_COMPILER=1
CPPFLAGS += -DLIB_PICO_MEM_OPS=1 -DLIB_PICO_MEM_OPS_COMPILER=1 -DLIB_PICO_NEWLIB_INTERFACE=1 -DLIB_PICO_PLATFORM=1
CPPFLAGS += -DLIB_PICO_PLATFORM_COMPILER=1 -DLIB_PICO_PLATFORM_PANIC=1 -DLIB_PICO_PLATFORM_SECTIONS=1 -DLIB_PICO_RUNTIME=1
CPPFLAGS += -DLIB_PICO_RUNTIME_INIT=1 -DLIB_PICO_STANDARD_BINARY_INFO=1 -DLIB_PICO_STANDARD_LINK=1 -DLIB_PICO_SYNC=1
CPPFLAGS += -DLIB_PICO_TIME=1 -DLIB_PICO_TIME_ADAPTER=1 -DLIB_PICO_UNIQUE_ID=1 -DLIB_PICO_UTIL=1 -DPICO_32BIT=1 -DPICO_BUILD=1
CPPFLAGS += -DPICO_COPY_TO_RAM=0 -DPICO_CXX_ENABLE_EXCEPTIONS=0 -DPICO_NO_FLASH=0 -DPICO_NO_HARDWARE=0 -DPICO_ON_DEVICE=1

RPI_LD_UNDEFINED += runtime_init_install_ram_vector_table __pre_init_runtime_init_clocks __pre_init_runtime_init_bootrom_reset
RPI_LD_UNDEFINED += __pre_init_runtime_init_early_resets __pre_init_runtime_init_usb_power_down __pre_init_runtime_init_clocks
RPI_LD_UNDEFINED += __pre_init_runtime_init_post_clock_resets __pre_init_runtime_init_spin_locks_reset __pre_init_runtime_init_boot_locks_reset
RPI_LD_UNDEFINED += __pre_init_runtime_init_bootrom_locking_enable __pre_init_runtime_init_mutex __pre_init_runtime_init_default_alarm_pool
RPI_LD_UNDEFINED += __pre_init_first_per_core_initializer __pre_init_runtime_init_per_core_bootrom_reset
RPI_LD_UNDEFINED += __pre_init_runtime_init_per_core_h3_irq_registers __pre_init_runtime_init_per_core_irq_priorities

RPI_LD_WRAP += acosb acosfb acoshb acoshfb __aeabi_cdcmpeqb __aeabi_cdcmpleb __aeabi_cdrcmpleb __aeabi_d2fb __aeabi_d2izb
RPI_LD_WRAP += __aeabi_d2lzb __aeabi_d2uiz __aeabi_d2ulz __aeabi_dadd __aeabi_dcmpeq __aeabi_dcmpge  __aeabi_dcmpgt __aeabi_dcmple
RPI_LD_WRAP += __aeabi_dcmplt __aeabi_dcmpun __aeabi_ddiv __aeabi_dmul __aeabi_drsub __aeabi_dsub __aeabi_i2d __aeabi_l2d
RPI_LD_WRAP += __aeabi_ui2d __aeabi_ul2d asin asinf asinh asinhf atan atan2 atan2f atanf atanh atanhf cbrt cbrtf ceil
RPI_LD_WRAP += ceilf copysign copysignf cos cosf cosh coshf __ctzdi2 drem dremf exp exp10 exp10f exp2 exp2f expf expm1
RPI_LD_WRAP += expm1f floor floorf fma fmaf fmod fmodf hypot hypotf ldexp ldexpf log log10 log10f log1p log1pf log2 log2f
RPI_LD_WRAP += logf pow powf powint powintf remainder remainderf remquo remquof round roundf sin sincos sincosf sinf sinh
RPI_LD_WRAP += sinhf sqrt tan tanf tanh tanhf trunc truncf memcpy

LDFLAGS += -Wl,--warn-section-align -Wl,--wrap=malloc,--wrap=free,--wrap=realloc,--wrap=calloc -u _printf_float -u_scanf_float
LDFLAGS += $(RPI_LD_UNDEFINED:%=-Wl,-u,%) $(RPI_LD_WRAP:%=-Wl,--wrap=%) -Wl,--no-warn-rwx-segments
LDFLAGS += -L$(RPI_BASE_PATH)/lib/$(CPU) -lpico -lipv4 -lbearssl
ARFLAGS := -rcs

RPI_SDK_SRC_INCLUDES += src/$(CPU)/hardware_regs/include src/$(CPU)/hardware_structs/include src/$(CPU)/pico_platform/include
RPI_SDK_SRC_INCLUDES += src/boards/include src/common/hardware_claim/include src/common/pico_base/include
RPI_SDK_SRC_INCLUDES += src/common/pico_base_headers/include src/common/pico_binary_info/include src/common/pico_bit_ops/include
RPI_SDK_SRC_INCLUDES += src/common/pico_divider/include src/common/pico_stdlib/include src/common/pico_sync/include
RPI_SDK_SRC_INCLUDES += src/common/pico_time/include src/common/pico_usb_reset_interface/include src/common/pico_util/include
RPI_SDK_SRC_INCLUDES += src/common/pico_stdlib_headers/include src/common/pico_usb_reset_interface_headers/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/cmsis/stub/CMSIS/Device/RP2350/Include src/rp2_common/hardware_sha256/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/pico_sha256/include src/rp2_common/pico_btstack/include src/rp2_common/pico_cyw43_arch/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/pico_cyw43_driver/include src/rp2_common/boot_bootrom_headers/include src/rp2_common/cmsis/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/cmsis/stub/CMSIS/Core/Include src/rp2_common/hardware_adc/include src/rp2_common/hardware_base/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/hardware_boot_lock/include src/rp2_common/hardware_clocks/include src/rp2_common/hardware_divider/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/hardware_dma/include src/rp2_common/hardware_exception/include src/rp2_common/hardware_flash/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/hardware_gpio/include src/rp2_common/hardware_i2c/include src/rp2_common/hardware_interp/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/hardware_irq/include src/rp2_common/hardware_rtc/include src/rp2_common/hardware_pio/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/hardware_pll/include src/rp2_common/hardware_pwm/include src/rp2_common/hardware_resets/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/hardware_spi/include src/rp2_common/hardware_sync/include src/rp2_common/hardware_sync_spin_lock/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/hardware_timer/include src/rp2_common/hardware_uart/include src/rp2_common/hardware_vreg/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/hardware_watchdog/include src/rp2_common/hardware_xosc/include src/rp2_common/pico_aon_timer/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/pico_async_context/include src/rp2_common/pico_bootrom/include src/rp2_common/pico_double/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/pico_fix/rp2040_usb_device_enumeration/include src/rp2_common/pico_flash/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/pico_float/include src/rp2_common/pico_int64_ops/include src/rp2_common/pico_lwip/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/pico_multicore/include src/rp2_common/pico_platform/include src/rp2_common/pico_platform_compiler/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/pico_platform_sections/include src/rp2_common/pico_platform_panic/include src/rp2_common/pico_printf/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/pico_runtime/include src/rp2_common/pico_runtime_init/include src/rp2_common/pico_rand/include
RPI_SDK_SRC_INCLUDES += src/rp2_common/pico_stdio/include src/rp2_common/pico_stdio_uart/include src/rp2_common/pico_unique_id/include

RPI_SDK_LIB_INCLUDES += lib/lwip/src/include lib/cyw43-driver/src lib/btstack/src lib/btstack/3rd-party/bluedroid/decoder/include
RPI_SDK_LIB_INCLUDES += lib/btstack/3rd-party/bluedroid/encoder/include lib/btstack/3rd-party/yxml lib/btstack/platform/embedded lib/tinyusb/src

CPPFLAGS += -iprefix "$(RPI_SDK_PATH)/src/" $(RPI_SDK_SRC_INCLUDES:%=-iwithprefixbefore "%") -iprefix "$(RPI_SDK_PATH)/lib/" $(RPI_SDK_LIB_INCLUDES:%=-iwithprefixbefore "%")
INCLUDE_PATHS += $(RPI_BASE_PATH)/include/$(CPU)
INCLUDE_PATHS += $(RPI_BASE_PATH)/include/$(CPU)/pico_base
INCLUDE_PATHS += $(RPI_BASE_PATH)/include
INCLUDE_PATHS += $(CORE_LIB_PATH)/Adafruit_TinyUSB_Arduino/src/arduino
INCLUDE_PATHS += $(CORE_PATH)/api/deprecated-avr-comp

include $(MAKE_INC_PATH)/Architectures/ARM/Targets.mk

%.uf2: %.elf $(SOURCES) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS) resetter
	@$(MSG) "[UF2]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)$(MAKE_PLATFORM_UTILS) --exec $(RPI_PICOTOOL) uf2 convert "$<" "$@" --family $(RPI_PICOTOOL_FAMILY) --abs-block \;

%.bin.signed: %.bin $(SOURCES) $(DEPENDENCY_LIB_PATHS) $(MODULES_LIBS)
	@$(MSG) "[UF2.SIGN]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)$(MAKE_PLATFORM_UTILS) --exec python3 -I "$(RPI_SIGNING)" "$(RPI_SIGNING_PRIVATE_KEY)" --bin "$<" --out "$@" \;

$(ARM_LD): $(ARM_LD_SOURCE)
	@$(MSG) "[ARMLD]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)$(MAKE_PLATFORM_UTILS) --exec python3 -I $(RPI_SIMPLESUB) --input "$<" --out "$@" --sub __FLASH_LENGTH__ $(RPI_FLASH_LENGTH) \
			--sub __EEPROM_START__ $(RPI_EEPROM_START) --sub __FS_START__ $(RPI_FS_START) --sub __FS_END__ $(RPI_FS_END) \
			--sub __RAM_LENGTH__ $(RPI_RAM_SIZE) --sub __PSRAM_LENGTH__ $(RPI_PSRAM_SIZE) \;

%.uf2.upload_rpi.timestamp: %.uf2 serial | silent
ifneq ($(strip $(NO_FIRMWARE_UPLOAD)),yes)
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$<)"

	$(V)$(MAKE_PLATFORM_UTILS) --exec python3 -I $(UF2CONV) --serial $(CPU_DEVICE_PORT) --family $(RPI_UF2_UPLOAD_FAMILY) --deploy "$<" \; \
		&& $(call write,"$(CPU_DEVICE_PORT)","$(BUILD_DIR)/.last_esp32_port") && $(TOUCH) "$@"
endif
upload_rpi: $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).uf2.upload_rpi.timestamp | silent
	@

.PRECIOUS: %.uf2
.PHONY: upload_rpi

