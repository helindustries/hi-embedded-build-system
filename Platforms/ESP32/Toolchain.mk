MCU_TOOLCHAIN := $(MCU)
ESP32_COMPILERPATH ?= $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/esp32/tools/xtensa-esp32-elf-gcc"/*/bin 2>/dev/null | sort | tail -n 1))
ESP32S2_COMPILERPATH ?= $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/esp32/tools/xtensa-esp32s2-elf-gcc"/*/bin 2>/dev/null | sort | tail -n 1))
ESP32S3_COMPILERPATH ?= $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/esp32/tools/xtensa-esp32s3-elf-gcc"/*/bin 2>/dev/null | sort | tail -n 1))
ifeq ($(strip $(MCU)),esp32)
	ESP_COMPILERPATH := $(ESP32_COMPILERPATH)
endif
ifeq ($(strip $(MCU)),esp32s2)
	ESP_COMPILERPATH := $(ESP32S2_COMPILERPATH)
endif
ifeq ($(strip $(MCU)),esp32s3)
	ESP_COMPILERPATH := $(ESP32S3_COMPILERPATH)
endif
MCU_TOOLCHAIN_OPTIONS := -DARDUINO_ARCH_ESP32

CC := $(ESP_COMPILERPATH)/xtensa-$(MCU)-elf-gcc
CXX := $(ESP_COMPILERPATH)/xtensa-$(MCU)-elf-g++
GDB := $(ESP_COMPILERPATH)/xtensa-$(MCU)-elf-gdb
AR := $(ESP_COMPILERPATH)/xtensa-$(MCU)-elf-gcc-ar
OBJCOPY := $(ESP_COMPILERPATH)/xtensa-$(MCU)-elf-objcopy
OBJDUMP := $(ESP_COMPILERPATH)/xtensa-$(MCU)-elf-objdump
SIZE := $(ESP_COMPILERPATH)/xtensa-$(MCU)-elf-size
START_GROUP := -Wl,--start-group
END_GROUP := -Wl,--end-group -Wl,-EL

ESP_BASE_PATH ?= $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/esp32/hardware/esp32"/* 2>/dev/null | sort | tail -n 1))
ESP_SDK_PATH ?= $(ESP_BASE_PATH)/tools/sdk
CORE_PATH := $(ESP_BASE_PATH)/cores/esp32
CORE_LIB_PATH := $(ESP_BASE_PATH)/libraries
CORE_VARIANTS_PATH := $(ESP_BASE_PATH)/variants

ESPTOOL ?= $(strip $(shell $(LS) "$(ARDUINO_USERPATH)/packages/esp32/tools/esptool_py"/*/esptool 2>/dev/null | sort | tail -n 1))
ESPGENPART_PY ?= $(strip $(shell $(LS) "$(ARDUINO_USERPATH)/packages/esp32/hardware/esp32"/*/tools/gen_esp32part.py 2>/dev/null | sort | tail -n 1))
ESPGENINSIGHT_PY ?= $(strip $(shell $(LS) "$(ARDUINO_USERPATH)/packages/esp32/hardware/esp32"/*/tools/gen_insights_package.py 2>/dev/null | sort | tail -n 1))
MCU_BOARD_PORT ?= $(strip $(shell for port in $(shell cat "$(BUILD_DIR)/.last_esp32_port" 2>/dev/null) "/dev/cu.usb"*; do if python3 "$$ESPTOOL" --port "$port" chip_id > /dev/null 2>&1; then echo "$port"; break; fi; done))

ifneq ($(strip $(ESP_BUILD_MINIMAL)),yes)
	ESP_INCLUDE_DIRS := esp_hw_support/include esp_hw_support/include/soc esp_hw_support/include/soc/$(MCU) esp_hw_support/port/$(MCU) esp_hw_support/port/$(MCU)/private_include
	ESP_INCLUDE_DIRS += esp_rom/include esp_rom/include/$(MCU) esp_rom/$(MCU) esp_common/include esp_system/include esp_system/port/soc esp_system/port/public_compat esp_pm/include
	ESP_INCLUDE_DIRS += esp_ringbuf/include esp_wifi/include esp_event/include esp_netif/include esp_eth/include esp_phy/include esp_phy/$(MCU)/include esp_ipc/include esp_timer/include
	ESP_INCLUDE_DIRS += esp_gdbstub/include esp_gdbstub/xtensa esp_gdbstub/$(MCU) esp-tls esp-tls/esp-tls-crypto esp_adc_cal/include esp_hid/include esp_local_ctrl/include
	ESP_INCLUDE_DIRS += esp_http_client/include esp_http_server/include esp_https_ota/include esp_https_server/include esp_lcd/include esp_lcd/interface esp_diagnostics/include
	ESP_INCLUDE_DIRS += esp_schedule/include esp_rainmaker/include esp_insights/include esp_littlefs/include esp_serial_slave_link/include esp_websocket_client/include
	ESP_INCLUDE_DIRS += esp-dsp/modules/dotprod/include esp-dsp/modules/support/include esp-dsp/modules/windows/include esp-dsp/modules/windows/hann/include
	ESP_INCLUDE_DIRS += esp-dsp/modules/windows/blackman/include esp-dsp/modules/windows/blackman_harris/include esp-dsp/modules/windows/blackman_nuttall/include
	ESP_INCLUDE_DIRS += esp-dsp/modules/windows/nuttall/include esp-dsp/modules/windows/flat_top/include esp-dsp/modules/iir/include esp-dsp/modules/fir/include
	ESP_INCLUDE_DIRS += esp-dsp/modules/math/include esp-dsp/modules/math/add/include esp-dsp/modules/math/sub/include esp-dsp/modules/math/mul/include
	ESP_INCLUDE_DIRS += esp-dsp/modules/math/addc/include esp-dsp/modules/math/mulc/include esp-dsp/modules/math/sqrt/include esp-dsp/modules/matrix/include
	ESP_INCLUDE_DIRS += esp-dsp/modules/fft/include esp-dsp/modules/dct/include esp-dsp/modules/conv/include esp-dsp/modules/common/include esp-dsp/modules/kalman/ekf/include
	ESP_INCLUDE_DIRS += esp-dsp/modules/kalman/ekf_imu13states/include esp-dl/include esp-dl/include/tool esp-dl/include/typedef esp-dl/include/image esp-dl/include/math
	ESP_INCLUDE_DIRS += esp-dl/include/nn esp-dl/include/layer esp-dl/include/detect esp-dl/include/model_zoo esp-sr/src/include esp-sr/esp-tts/esp_tts_chinese/include
	ESP_INCLUDE_DIRS += esp-sr/include/$(MCU) esp32-camera/driver/include esp32-camera/conversions/include hal/$(MCU)/include hal/include hal/platform_port/include
	ESP_INCLUDE_DIRS += espcoredump/include espcoredump/include/port/xtensa wpa_supplicant/include wpa_supplicant/port/include wpa_supplicant/esp_supplicant/include
	ESP_INCLUDE_DIRS += xtensa/include xtensa/$(MCU)/include driver/include driver/$(MCU)/include efuse/include efuse/$(MCU)/include asio/asio/asio/include asio/port/include
	ESP_INCLUDE_DIRS += bt/common/osi/include bt/include/$(MCU)/include bt/common/api/include/api bt/common/btc/profile/esp/blufi/include bt/common/btc/profile/esp/include
	ESP_INCLUDE_DIRS += bt/host/bluedroid/api/include/api bt/esp_ble_mesh/mesh_common/include bt/esp_ble_mesh/mesh_common/tinycrypt/include bt/esp_ble_mesh/mesh_core
	ESP_INCLUDE_DIRS += bt/esp_ble_mesh/mesh_core/include bt/esp_ble_mesh/mesh_core/storage bt/esp_ble_mesh/btc/include bt/esp_ble_mesh/mesh_models/common/include
	ESP_INCLUDE_DIRS += bt/esp_ble_mesh/mesh_models/client/include bt/esp_ble_mesh/mesh_models/server/include bt/esp_ble_mesh/api/core/include bt/esp_ble_mesh/api/models/include
	ESP_INCLUDE_DIRS += bt/esp_ble_mesh/api ws2812_led rtc_store/include fb_gfx/include rmaker_common/include gpio_button/button/include qrcode/include wifi_provisioning/include
	ESP_INCLUDE_DIRS += lwip/include/apps lwip/include/apps/sntp lwip/lwip/src/include lwip/port/esp32/include lwip/port/esp32/include/arch soc/include soc/$(MCU) soc/$(MCU)/include
	ESP_INCLUDE_DIRS += freertos/include freertos/include/esp_additions/freertos freertos/port/xtensa/include freertos/include/esp_additions coap/port/include coap/libcoap/include
	ESP_INCLUDE_DIRS += expat/expat/expat/lib expat/port/include unity/include unity/unity/src fatfs/diskio fatfs/vfs fatfs/src idf_test/include idf_test/include/$(MCU)
	ESP_INCLUDE_DIRS += mbedtls/port/include mbedtls/mbedtls/include mbedtls/esp_crt_bundle/include libsodium/libsodium/src/libsodium/include libsodium/port_include
	ESP_INCLUDE_DIRS += nghttp/port/include nghttp/nghttp2/lib/includes jsmn/include json/cJSON json_parser/upstream/include json_parser/upstream json_generator/upstream
	ESP_INCLUDE_DIRS += protocomm/include/common protocomm/include/security protocomm/include/transports freertos/include/freertos arduino_tinyusb/tinyusb/src arduino_tinyusb/include
	ESP_INCLUDE_DIRS += newlib/platform_include heap/include log/include vfs/include tcpip_adapter/include app_trace/include app_update/include spi_flash/include
	ESP_INCLUDE_DIRS += bootloader_support/include nvs_flash/include pthread/include ieee802154/include console cbor/port/include cmock/CMock/src tcp_transport/include
	ESP_INCLUDE_DIRS += protobuf-c/protobuf-c mdns/include sdmmc/include wear_levelling/include freemodbus/freemodbus/common/include mqtt/esp-mqtt/include openssl/include
	ESP_INCLUDE_DIRS += perfmon/include spiffs/include usb/include ulp/include
endif

ELF_MAP := $(MCU_TARGET).$(MCU_BOARD).map
ESP_DEBUG_LEVEL ?= 0
ESP_MAIN_CORE ?= 1
ESP_EVENT_CORE ?= 1

# CPPFLAGS = compiler options for C and C++
CPPFLAGS ?=
CPPFLAGS += $(OPTIMIZE) $(MCU_OPTIONS) -mlongcalls -MMD -ggdb
CPPFLAGS += -ffunction-sections -fdata-sections -freorder-blocks -fstack-protector -fstrict-volatile-bitfields -fno-jump-tables -fno-tree-switch-conversion -fno-lto -Wwrite-strings
CPPFLAGS += -Wall -Wno-error=deprecated-declarations -Wno-unused-parameter  -Wno-error=narrowing -Wno-error=unused-function -Wno-error=unused-variable -Wno-error=unused-but-set-variable
CPPFLAGS += -DARDUINO_ARCH_ESP32 -DESP_PLATFORM -DHAVE_CONFIG_H -DUNITY_INCLUDE_CONFIG_H -D_GNU_SOURCE -DWITH_POSIX -D_POSIX_READER_WRITER_LOCKS -DARDUINO_PARTITION_default -Wno-sign-compare
CPPFLAGS += -DARDUINO_USB_CDC_ON_BOOT=1 -DARDUINO_USB_MSC_ON_BOOT=0 -DARDUINO_USB_DFU_ON_BOOT=0 -DARDUINO_USB_MODE=1 "-DMBEDTLS_CONFIG_FILE=\"mbedtls\/esp_config\.h\"" "-DIDF_VER=\"v4\.4\.4\""
CPPFLAGS += -DCORE_DEBUG_LEVEL=$(ESP_DEBUG_LEVEL) -DARDUINO_RUNNING_CORE=$(ESP_MAIN_CORE) -DARDUINO_EVENT_RUNNING_CORE=$(ESP_EVENT_CORE) -DESP32
ifeq ($(strip $(ESP_WITH_PSRAM)), yes)
	CPPFLAGS += -DBOARD_HAS_PSRAM
endif

INCLUDE_PATHS += "$(ESP_SDK_PATH)/$(MCU_TOOLCHAIN)/qio_qspi/include"
INCLUDE_PATHS += $(ESP_INCLUDE_DIRS:%="$(ESP_SDK_PATH)/$(MCU_TOOLCHAIN)/include/%")

# compiler options for C++ only
CXXFLAGS ?=
CXXFLAGS += -fno-exceptions
#CXXFLAGS += -fexceptions
CXXFLAGS += -fno-rtti
CXXFLAGS += -fpermissive -felide-constructors -fno-threadsafe-statics

# compiler options for C only
CFLAGS ?=

# additional libraries to link
ifneq ($(strip $(ESP_BUILD_MINIMAL)),yes)
	ESP_LD_LIBRARIES := esp_ringbuf efuse esp_ipc driver esp_pm mbedtls app_update bootloader_support spi_flash nvs_flash pthread esp_gdbstub espcoredump esp_phy esp_system esp_rom hal vfs
	ESP_LD_LIBRARIES += esp_eth tcpip_adapter esp_netif esp_event wpa_supplicant esp_wifi console lwip log heap soc esp_hw_support xtensa esp_common esp_timer freertos newlib cxx app_trace
	ESP_LD_LIBRARIES += asio bt cbor unity cmock coap nghttp esp-tls esp_adc_cal esp_hid tcp_transport esp_http_client esp_http_server esp_https_ota esp_https_server esp_lcd protobuf-c
	ESP_LD_LIBRARIES += protocomm mdns esp_local_ctrl sdmmc esp_serial_slave_link esp_websocket_client expat wear_levelling fatfs freemodbus jsmn json libsodium mqtt openssl perfmon spiffs
	ESP_LD_LIBRARIES += usb ulp wifi_provisioning rmaker_common json_parser json_generator esp_schedule esp_rainmaker gpio_button qrcode ws2812_led esp_diagnostics rtc_store esp_insights
	ESP_LD_LIBRARIES += esp-dsp esp-sr esp32-camera esp_littlefs fb_gfx btdm_app arduino_tinyusb cat_face_detect human_face_detect color_detect mfn dl esp_audio_front_end esp_audio_processor
	ESP_LD_LIBRARIES += multinet wakenet hufzip dl_lib c_speech_features esp_tts_chinese voice_set_xiaole mbedtls_2 mbedcrypto mbedx509 coexist espnow mesh net80211 pp smartconfig wapi
	ESP_LD_LIBRARIES += phy btbb xt_hal gcc gcov c
	ESP_LD_LIBRARY_SEARCH_DIRS := lib ld qio_qspi
	ESP_LD_LIBRARY_DEFS := memory.ld sections.ld $(MCU).rom.ld $(MCU).rom.api.ld $(MCU).rom.libgcc.ld $(MCU).rom.newlib.ld $(MCU).rom.version.ld $(MCU).rom.newlib-time.ld $(MCU).peripherals.ld
endif

# linker options
ESP_LD_SYMBOLS := _Z5setupv _Z4loopv esp_app_desc pthread_include_pthread_impl pthread_include_pthread_cond_impl pthread_include_pthread_local_storage_impl pthread_include_pthread_rwlock_impl
ESP_LD_SYMBOLS += include_esp_phy_override ld_include_highint_hdl start_app start_app_other_cores __ubsan_include __assert_func vfs_include_syscalls_impl app_main newlib_include_heap_impl
ESP_LD_SYMBOLS += newlib_include_syscalls_impl newlib_include_pthread_impl newlib_include_assert_impl __cxa_guard_dummy
ESP_LD_UNDEFINED := esp_kiss_fftndr_alloc esp_kiss_fftndri esp_kiss_fftndr
ESP_LD_OPTIONS := --cref --gc-sections --wrap=esp_log_write --wrap=esp_log_writev --wrap=log_printf --wrap=longjmp --undefined=uxTopUsedPriority --defsym=__rtc_localtime=$(shell date +%s)
LDFLAGS += $(ESP_LD_LIBRARY_DEFS:%=-T %) $(OPTIMIZE) $(ESP_LD_OPTIONS:%=-Wl,%) $(ESP_LD_UNDEFINED:%=-Wl,-u,%)
LDFLAGS += -mlongcalls -ffunction-sections -fdata-sections -freorder-blocks -fstack-protector -fstrict-volatile-bitfields -fno-jump-tables -fno-tree-switch-conversion -fno-rtti -fno-lto -Wwrite-strings
LDFLAGS += $(ESP_LD_SYMBOLS:%=-u %) -fno-use-linker-plugin

LIBRARY_PATHS += $(ESP_LD_LIBRARY_SEARCH_DIRS:%="$(ESP_SDK_PATH)/$(MCU_TOOLCHAIN)/%")
LIBS += $(ESP_LD_LIBRARIES) c m stdc++
