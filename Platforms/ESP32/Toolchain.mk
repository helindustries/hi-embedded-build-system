MCU_TOOLCHAIN := $(MCU)
ESP_COMPILERPATH ?= $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/esp32/tools/esp-x32"/*/bin 2>/dev/null | sort | tail -n 1))
ifeq ($(strip $(ESP_COMPILERPATH)),)
    # Arduino plugin v2.x
    ESP_COMPILERPATH := $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/esp32/tools/xtensa-$(MCU_TOOLCHAIN)-elf-gcc"/*/bin 2>/dev/null | sort | tail -n 1))
    ESP_SDK_VERSION := 2
else
    ESP_SDK_VERSION := 3
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
END_GROUP := -Wl,--end-group

ESP_SDK_PATH ?= $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/esp32/tools/esp32-arduino-libs"/* 2>/dev/null | sort | tail -n 1))
ESP_BASE_PATH ?= $(strip $(shell $(LS) -d "$(ARDUINO_USERPATH)/packages/esp32/hardware/esp32"/* 2>/dev/null | sort | tail -n 1))
ifeq ($(strip $(ESP_SDK_PATH)),)
    # Arduino plugin v2.x
    ESP_SDK_PATH := $(ESP_BASE_PATH)/tools/sdk
endif
CORE_PATH := $(ESP_BASE_PATH)/cores/esp32
CORE_LIB_PATH := $(ESP_BASE_PATH)/libraries
CORE_VARIANTS_PATH := $(ESP_BASE_PATH)/variants

ESPTOOL ?= $(strip $(shell $(LS) "$(ARDUINO_USERPATH)/packages/esp32/tools/esptool_py"/*/esptool 2>/dev/null | sort | tail -n 1))
ESPGENPART_PY ?= $(strip $(shell $(LS) "$(ARDUINO_USERPATH)/packages/esp32/hardware/esp32"/*/tools/gen_esp32part.py 2>/dev/null | sort | tail -n 1))
ESPGENINSIGHT_PY ?= $(strip $(shell $(LS) "$(ARDUINO_USERPATH)/packages/esp32/hardware/esp32"/*/tools/gen_insights_package.py 2>/dev/null | sort | tail -n 1))
MCU_BOARD_PORT ?= $(strip $(shell for port in $(shell cat "$(BUILD_DIR)/.last_esp32_port" 2>/dev/null) "/dev/cu.usb"*; do if python3 "$$ESPTOOL" --port "$port" chip_id > /dev/null 2>&1; then echo "$port"; break; fi; done))

ifneq ($(strip $(ESP_BUILD_MINIMAL)),yes)
ifeq ($(strip $(ESP_SDK_VERSION)),2)
    ESP_INCLUDE_DIRS += app_trace/include app_update/include arduino_tinyusb/include arduino_tinyusb/tinyusb/src asio/asio/asio/include asio/port/include bootloader_support/include
    ESP_INCLUDE_DIRS += bt/common/api/include/api bt/common/btc/profile/esp/blufi/include bt/common/btc/profile/esp/include bt/common/osi/include bt/esp_ble_mesh/api
    ESP_INCLUDE_DIRS += bt/esp_ble_mesh/api/core/include bt/esp_ble_mesh/api/models/include bt/esp_ble_mesh/btc/include bt/esp_ble_mesh/mesh_common/include
    ESP_INCLUDE_DIRS += bt/esp_ble_mesh/mesh_common/tinycrypt/include bt/esp_ble_mesh/mesh_core bt/esp_ble_mesh/mesh_core/include bt/esp_ble_mesh/mesh_core/storage
    ESP_INCLUDE_DIRS += bt/esp_ble_mesh/mesh_models/client/include bt/esp_ble_mesh/mesh_models/common/include bt/esp_ble_mesh/mesh_models/server/include bt/host/bluedroid/api/include/api
    ESP_INCLUDE_DIRS += bt/include/esp32c3/include cbor/port/include cmock/CMock/src coap/libcoap/include coap/port/include console driver/esp32s3/include driver/include
    ESP_INCLUDE_DIRS += efuse/esp32s3/include efuse/include esp-dl/include esp-dl/include/detect esp-dl/include/image esp-dl/include/layer esp-dl/include/math esp-dl/include/model_zoo
    ESP_INCLUDE_DIRS += esp-dl/include/nn esp-dl/include/tool esp-dl/include/typedef esp-tls esp-tls/esp-tls-crypto esp32-camera/conversions/include esp32-camera/driver/include
    ESP_INCLUDE_DIRS += esp_adc_cal/include esp_common/include esp_diagnostics/include esp_eth/include esp_event/include esp_gdbstub/esp32s3 esp_gdbstub/include esp_gdbstub/xtensa
    ESP_INCLUDE_DIRS += esp_hid/include esp_http_client/include esp_http_server/include esp_https_ota/include esp_https_server/include esp_hw_support/include esp_hw_support/include/soc
    ESP_INCLUDE_DIRS += esp_hw_support/include/soc/esp32s3 esp_hw_support/port/esp32s3 esp_hw_support/port/esp32s3/private_include esp_insights/include esp_ipc/include esp_lcd/include
    ESP_INCLUDE_DIRS += esp_lcd/interface esp_littlefs/include esp_local_ctrl/include esp_netif/include esp_phy/esp32s3/include esp_phy/include esp_pm/include esp_rainmaker/include
    ESP_INCLUDE_DIRS += esp_ringbuf/include esp_rom/esp32s3 esp_rom/include esp_rom/include/esp32s3 esp_schedule/include esp_serial_slave_link/include esp_system/include
    ESP_INCLUDE_DIRS += esp_system/port/public_compat esp_system/port/soc esp_timer/include esp_websocket_client/include esp_wifi/include espcoredump/include espcoredump/include/port/xtensa
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/common/include espressif__esp-dsp/modules/conv/include espressif__esp-dsp/modules/dct/include espressif__esp-dsp/modules/dotprod/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/fft/include espressif__esp-dsp/modules/fir/include espressif__esp-dsp/modules/iir/include espressif__esp-dsp/modules/kalman/ekf/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/kalman/ekf_imu13states/include espressif__esp-dsp/modules/math/add/include espressif__esp-dsp/modules/math/addc/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/math/include espressif__esp-dsp/modules/math/mul/include espressif__esp-dsp/modules/math/mulc/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/math/sqrt/include espressif__esp-dsp/modules/math/sub/include espressif__esp-dsp/modules/matrix/add/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/matrix/addc/include espressif__esp-dsp/modules/matrix/include espressif__esp-dsp/modules/matrix/mul/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/matrix/mul/test/include espressif__esp-dsp/modules/matrix/mulc/include espressif__esp-dsp/modules/matrix/sub/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/support/include espressif__esp-dsp/modules/support/mem/include espressif__esp-dsp/modules/windows/blackman/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/windows/blackman_harris/include espressif__esp-dsp/modules/windows/blackman_nuttall/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/windows/flat_top/include espressif__esp-dsp/modules/windows/hann/include espressif__esp-dsp/modules/windows/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/windows/nuttall/include espressif__esp_secure_cert_mgr/include expat/expat/expat/lib expat/port/include fatfs/diskio fatfs/src
    ESP_INCLUDE_DIRS += fatfs/vfs fb_gfx/include freemodbus/freemodbus/common/include freertos/include freertos/include/esp_additions freertos/include/esp_additions/freertos
    ESP_INCLUDE_DIRS += freertos/include/freertos freertos/port/xtensa/include gpio_button/button/include hal/esp32s3/include hal/include hal/platform_port/include heap/include
    ESP_INCLUDE_DIRS += idf_test/include idf_test/include/esp32s3 ieee802154/include jsmn/include json/cJSON json_generator/upstream json_parser/upstream json_parser/upstream/include
    ESP_INCLUDE_DIRS += libsodium/libsodium/src/libsodium/include libsodium/port_include log/include lwip/include/apps lwip/include/apps/sntp lwip/lwip/src/include lwip/port/esp32/include
    ESP_INCLUDE_DIRS += lwip/port/esp32/include/arch mbedtls/esp_crt_bundle/include mbedtls/mbedtls/include mbedtls/port/include mdns/include mqtt/esp-mqtt/include
    ESP_INCLUDE_DIRS += newlib/platform_include nghttp/nghttp2/lib/includes nghttp/port/include nvs_flash/include openssl/include perfmon/include protobuf-c/protobuf-c
    ESP_INCLUDE_DIRS += protocomm/include/common protocomm/include/security protocomm/include/transports pthread/include qrcode/include rmaker_common/include rtc_store/include
    ESP_INCLUDE_DIRS += sdmmc/include soc/esp32s3 soc/esp32s3/include soc/include spi_flash/include spiffs/include tcp_transport/include tcpip_adapter/include ulp/include unity/include
    ESP_INCLUDE_DIRS += unity/unity/src usb/include vfs/include wear_levelling/include wifi_provisioning/include wpa_supplicant/esp_supplicant/include wpa_supplicant/include
    ESP_INCLUDE_DIRS += wpa_supplicant/port/include ws2812_led xtensa/esp32s3/include xtensa/include
    # Old 2.0.7 Includes
	#ESP_INCLUDE_DIRS := esp_hw_support/include esp_hw_support/include/soc esp_hw_support/include/soc/$(MCU) esp_hw_support/port/$(MCU) esp_hw_support/port/$(MCU)/private_include
	#ESP_INCLUDE_DIRS += esp_rom/include esp_rom/include/$(MCU) esp_rom/$(MCU) esp_common/include esp_system/include esp_system/port/soc esp_system/port/public_compat esp_pm/include
	#ESP_INCLUDE_DIRS += esp_ringbuf/include esp_wifi/include esp_event/include esp_netif/include esp_eth/include esp_phy/include esp_phy/$(MCU)/include esp_ipc/include esp_timer/include
	#ESP_INCLUDE_DIRS += esp_gdbstub/include esp_gdbstub/xtensa esp_gdbstub/$(MCU) esp-tls esp-tls/esp-tls-crypto esp_adc_cal/include esp_hid/include esp_local_ctrl/include
	#ESP_INCLUDE_DIRS += esp_http_client/include esp_http_server/include esp_https_ota/include esp_https_server/include esp_lcd/include esp_lcd/interface esp_diagnostics/include
	#ESP_INCLUDE_DIRS += esp_schedule/include esp_rainmaker/include esp_insights/include esp_littlefs/include esp_serial_slave_link/include esp_websocket_client/include
	#ESP_INCLUDE_DIRS += esp-dsp/modules/dotprod/include esp-dsp/modules/support/include esp-dsp/modules/windows/include esp-dsp/modules/windows/hann/include
	#ESP_INCLUDE_DIRS += esp-dsp/modules/windows/blackman/include esp-dsp/modules/windows/blackman_harris/include esp-dsp/modules/windows/blackman_nuttall/include
	#ESP_INCLUDE_DIRS += esp-dsp/modules/windows/nuttall/include esp-dsp/modules/windows/flat_top/include esp-dsp/modules/iir/include esp-dsp/modules/fir/include
	#ESP_INCLUDE_DIRS += esp-dsp/modules/math/include esp-dsp/modules/math/add/include esp-dsp/modules/math/sub/include esp-dsp/modules/math/mul/include
	#ESP_INCLUDE_DIRS += esp-dsp/modules/math/addc/include esp-dsp/modules/math/mulc/include esp-dsp/modules/math/sqrt/include esp-dsp/modules/matrix/include
	#ESP_INCLUDE_DIRS += esp-dsp/modules/fft/include esp-dsp/modules/dct/include esp-dsp/modules/conv/include esp-dsp/modules/common/include esp-dsp/modules/kalman/ekf/include
	#ESP_INCLUDE_DIRS += esp-dsp/modules/kalman/ekf_imu13states/include esp-dl/include esp-dl/include/tool esp-dl/include/typedef esp-dl/include/image esp-dl/include/math
	#ESP_INCLUDE_DIRS += esp-dl/include/nn esp-dl/include/layer esp-dl/include/detect esp-dl/include/model_zoo esp-sr/src/include esp-sr/esp-tts/esp_tts_chinese/include
	#ESP_INCLUDE_DIRS += esp-sr/include/$(MCU) esp32-camera/driver/include esp32-camera/conversions/include hal/$(MCU)/include hal/include hal/platform_port/include
	#ESP_INCLUDE_DIRS += espcoredump/include espcoredump/include/port/xtensa wpa_supplicant/include wpa_supplicant/port/include wpa_supplicant/esp_supplicant/include
	#ESP_INCLUDE_DIRS += xtensa/include xtensa/$(MCU)/include driver/include driver/$(MCU)/include efuse/include efuse/$(MCU)/include asio/asio/asio/include asio/port/include
	#ESP_INCLUDE_DIRS += bt/common/osi/include bt/include/$(MCU)/include bt/common/api/include/api bt/common/btc/profile/esp/blufi/include bt/common/btc/profile/esp/include
	#ESP_INCLUDE_DIRS += bt/host/bluedroid/api/include/api bt/esp_ble_mesh/mesh_common/include bt/esp_ble_mesh/mesh_common/tinycrypt/include bt/esp_ble_mesh/mesh_core
	#ESP_INCLUDE_DIRS += bt/esp_ble_mesh/mesh_core/include bt/esp_ble_mesh/mesh_core/storage bt/esp_ble_mesh/btc/include bt/esp_ble_mesh/mesh_models/common/include
	#ESP_INCLUDE_DIRS += bt/esp_ble_mesh/mesh_models/client/include bt/esp_ble_mesh/mesh_models/server/include bt/esp_ble_mesh/api/core/include bt/esp_ble_mesh/api/models/include
	#ESP_INCLUDE_DIRS += bt/esp_ble_mesh/api ws2812_led rtc_store/include fb_gfx/include rmaker_common/include gpio_button/button/include qrcode/include wifi_provisioning/include
	#ESP_INCLUDE_DIRS += lwip/include/apps lwip/include/apps/sntp lwip/lwip/src/include lwip/port/esp32/include lwip/port/esp32/include/arch soc/include soc/$(MCU) soc/$(MCU)/include
	#ESP_INCLUDE_DIRS += freertos/include freertos/include/esp_additions/freertos freertos/port/xtensa/include freertos/include/esp_additions coap/port/include coap/libcoap/include
	#ESP_INCLUDE_DIRS += expat/expat/expat/lib expat/port/include unity/include unity/unity/src fatfs/diskio fatfs/vfs fatfs/src idf_test/include idf_test/include/$(MCU)
	#ESP_INCLUDE_DIRS += mbedtls/port/include mbedtls/mbedtls/include mbedtls/esp_crt_bundle/include libsodium/libsodium/src/libsodium/include libsodium/port_include
	#ESP_INCLUDE_DIRS += nghttp/port/include nghttp/nghttp2/lib/includes jsmn/include json/cJSON json_parser/upstream/include json_parser/upstream json_generator/upstream
	#ESP_INCLUDE_DIRS += protocomm/include/common protocomm/include/security protocomm/include/transports freertos/include/freertos arduino_tinyusb/tinyusb/src arduino_tinyusb/include
	#ESP_INCLUDE_DIRS += newlib/platform_include heap/include log/include vfs/include tcpip_adapter/include app_trace/include app_update/include spi_flash/include
	#ESP_INCLUDE_DIRS += bootloader_support/include nvs_flash/include pthread/include ieee802154/include console cbor/port/include cmock/CMock/src tcp_transport/include
	#ESP_INCLUDE_DIRS += protobuf-c/protobuf-c mdns/include sdmmc/include wear_levelling/include freemodbus/freemodbus/common/include mqtt/esp-mqtt/include openssl/include
	#ESP_INCLUDE_DIRS += perfmon/include spiffs/include usb/include ulp/include
else
	# Arduino plugin v3.x
    ESP_INCLUDE_DIRS += newlib/platform_include freertos/config/include freertos/config/include/freertos freertos/config/xtensa/include freertos/FreeRTOS-Kernel/include
    ESP_INCLUDE_DIRS += freertos/FreeRTOS-Kernel/portable/xtensa/include freertos/FreeRTOS-Kernel/portable/xtensa/include/freertos freertos/esp_additions/include esp_hw_support/include
    ESP_INCLUDE_DIRS += esp_hw_support/include/soc esp_hw_support/include/soc/esp32s3 esp_hw_support/dma/include esp_hw_support/ldo/include esp_hw_support/port/esp32s3
    ESP_INCLUDE_DIRS += esp_hw_support/port/esp32s3/include heap/include log/include soc/include soc/esp32s3 soc/esp32s3/include hal/platform_port/include hal/esp32s3/include
    ESP_INCLUDE_DIRS += hal/include esp_rom/include esp_rom/include/esp32s3 esp_rom/esp32s3 esp_common/include esp_system/include esp_system/port/soc esp_system/port/include/private
    ESP_INCLUDE_DIRS += xtensa/esp32s3/include xtensa/include xtensa/deprecated_include esp_timer/include lwip/include lwip/include/apps lwip/include/apps/sntp lwip/lwip/src/include
    ESP_INCLUDE_DIRS += lwip/port/include lwip/port/freertos/include lwip/port/esp32xx/include lwip/port/esp32xx/include/arch lwip/port/esp32xx/include/sys espressif__esp-tflite-micro
    ESP_INCLUDE_DIRS += espressif__esp-tflite-micro/third_party/gemmlowp espressif__esp-tflite-micro/third_party/flatbuffers/include espressif__esp-tflite-micro/third_party/ruy
    ESP_INCLUDE_DIRS += espressif__esp-tflite-micro/third_party/kissfft espressif__esp-tflite-micro/signal/micro/kernels espressif__esp-tflite-micro/signal/src
    ESP_INCLUDE_DIRS += espressif__esp-tflite-micro/signal/src/kiss_fft_wrappers espressif__esp32-camera/driver/include espressif__esp32-camera/conversions/include driver/deprecated
    ESP_INCLUDE_DIRS += driver/i2c/include driver/touch_sensor/include driver/twai/include driver/touch_sensor/esp32s3/include esp_pm/include esp_ringbuf/include esp_driver_gpio/include
    ESP_INCLUDE_DIRS += esp_driver_pcnt/include esp_driver_gptimer/include esp_driver_spi/include esp_driver_mcpwm/include esp_driver_ana_cmpr/include esp_driver_i2s/include
    ESP_INCLUDE_DIRS += esp_driver_sdmmc/include sdmmc/include esp_driver_sdspi/include esp_driver_sdio/include esp_driver_dac/include esp_driver_rmt/include esp_driver_tsens/include
    ESP_INCLUDE_DIRS += esp_driver_sdm/include esp_driver_i2c/include esp_driver_uart/include vfs/include esp_driver_ledc/include esp_driver_parlio/include
    ESP_INCLUDE_DIRS += esp_driver_usb_serial_jtag/include espressif__esp_matter/connectedhomeip/connectedhomeip/src espressif__esp_matter/connectedhomeip/connectedhomeip/src/include
    ESP_INCLUDE_DIRS += espressif__esp_matter/connectedhomeip/connectedhomeip/src/lib espressif__esp_matter/connectedhomeip/connectedhomeip/src/lib/dnssd
    ESP_INCLUDE_DIRS += espressif__esp_matter/connectedhomeip/connectedhomeip/src/platform/OpenThread espressif__esp_matter/connectedhomeip/connectedhomeip/third_party/nlfaultinjection/include
    ESP_INCLUDE_DIRS += espressif__esp_matter/connectedhomeip/connectedhomeip/third_party/nlassert/repo/include espressif__esp_matter/connectedhomeip/connectedhomeip/third_party/nlio/repo/include
    ESP_INCLUDE_DIRS += espressif__esp_matter/connectedhomeip/connectedhomeip/zzz_generated/app-common esp-idf/espressif__esp_matter esp_matter esp_matter/utils esp_matter_bridge
    ESP_INCLUDE_DIRS += esp_matter_console esp_matter/zap_common espressif__esp_matter/connectedhomeip/connectedhomeip/src/platform/ESP32 bt/esp_ble_mesh/v1.1/api/models/include
    ESP_INCLUDE_DIRS += espressif__esp_matter/connectedhomeip/connectedhomeip/src/platform/ESP32/bluedroid espressif__esp_matter/connectedhomeip/connectedhomeip/src/platform/ESP32/nimble
    ESP_INCLUDE_DIRS += espressif__esp_matter/connectedhomeip/connectedhomeip/src/platform/ESP32/route_hook esp_eth/include esp_event/include bt/include/esp32c3/include
    ESP_INCLUDE_DIRS += bt/common/osi/include bt/common/api/include/api bt/common/btc/profile/esp/blufi/include bt/common/btc/profile/esp/include bt/common/hci_log/include
    ESP_INCLUDE_DIRS += bt/host/bluedroid/api/include/api bt/esp_ble_mesh/common/include bt/esp_ble_mesh/common/tinycrypt/include bt/esp_ble_mesh/core bt/esp_ble_mesh/core/include
    ESP_INCLUDE_DIRS += bt/esp_ble_mesh/core/storage bt/esp_ble_mesh/btc/include bt/esp_ble_mesh/models/common/include bt/esp_ble_mesh/models/client/include bt/esp_ble_mesh/models/server/include
    ESP_INCLUDE_DIRS += bt/esp_ble_mesh/api/core/include bt/esp_ble_mesh/api/models/include bt/esp_ble_mesh/api bt/esp_ble_mesh/lib/include bt/esp_ble_mesh/v1.1/api/core/include
    ESP_INCLUDE_DIRS += bt/esp_ble_mesh/v1.1/btc/include bt/porting/ext/tinycrypt/include esp_wifi/include esp_wifi/wifi_apps/include esp_wifi/wifi_apps/nan_app/include esp_wifi/include/local
    ESP_INCLUDE_DIRS += esp_phy/include esp_phy/esp32s3/include esp_netif/include mbedtls/port/include mbedtls/mbedtls/include mbedtls/mbedtls/library mbedtls/esp_crt_bundle/include
    ESP_INCLUDE_DIRS += mbedtls/mbedtls/3rdparty/everest/include mbedtls/mbedtls/3rdparty/p256-m mbedtls/mbedtls/3rdparty/p256-m/p256-m fatfs/diskio fatfs/src fatfs/vfs wear_levelling/include
    ESP_INCLUDE_DIRS += esp_partition/include app_update/include bootloader_support/include bootloader_support/bootloader_flash/include esp_app_format/include esp_bootloader_format/include
    ESP_INCLUDE_DIRS += console esp_vfs_console/include nvs_flash/include spi_flash/include espressif__esp_secure_cert_mgr/include efuse/include efuse/esp32s3/include
    ESP_INCLUDE_DIRS += espressif__json_parser/include espressif__jsmn/include spiffs/include esp_http_client/include espressif__json_generator/include json/cJSON espressif__mdns/include
    ESP_INCLUDE_DIRS += espressif__esp_encrypted_img/include espressif__esp_insights/include espressif__esp_diagnostics/include espressif__esp-sr/src/include
    ESP_INCLUDE_DIRS += espressif__esp-sr/esp-tts/esp_tts_chinese/include espressif__esp-sr/include/esp32s3 esp_mm/include pthread/include app_trace/include wpa_supplicant/include
    ESP_INCLUDE_DIRS += wpa_supplicant/port/include wpa_supplicant/esp_supplicant/include esp_coex/include unity/include unity/unity/src cmock/CMock/src http_parser esp-tls
    ESP_INCLUDE_DIRS += esp-tls/esp-tls-crypto esp_adc/include esp_adc/interface esp_adc/esp32s3/include esp_adc/deprecated/include esp_driver_isp/include esp_driver_cam/include
    ESP_INCLUDE_DIRS += esp_driver_cam/interface esp_driver_jpeg/include esp_driver_ppa/include esp_gdbstub/include esp_hid/include tcp_transport/include esp_http_server/include
    ESP_INCLUDE_DIRS += esp_https_ota/include esp_https_server/include esp_psram/include esp_lcd/include esp_lcd/interface esp_lcd/rgb/include protobuf-c/protobuf-c protocomm/include/common
    ESP_INCLUDE_DIRS += protocomm/include/security protocomm/include/transports protocomm/include/crypto/srp6a protocomm/proto-c esp_local_ctrl/include espcoredump/include
    ESP_INCLUDE_DIRS += espcoredump/include/port/xtensa idf_test/include idf_test/include/esp32s3 ieee802154/include mqtt/esp-mqtt/include nvs_sec_provider/include perfmon/include
    ESP_INCLUDE_DIRS += touch_element/include ulp/ulp_common/include ulp/ulp_fsm/include ulp/ulp_fsm/include/esp32s3 usb/include wifi_provisioning/include espressif__esp-nn/include
    ESP_INCLUDE_DIRS += espressif__esp-nn/src/common espressif__rmaker_common/include espressif__cbor/port/include espressif__esp_diag_data_store/src/rtc_store
    ESP_INCLUDE_DIRS += espressif__esp_diag_data_store/include espressif__esp-dsp/modules/dotprod/include espressif__esp-dsp/modules/support/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/support/mem/include espressif__esp-dsp/modules/windows/include espressif__esp-dsp/modules/windows/hann/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/windows/blackman/include espressif__esp-dsp/modules/windows/blackman_harris/include espressif__esp-dsp/modules/windows/blackman_nuttall/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/windows/nuttall/include espressif__esp-dsp/modules/windows/flat_top/include espressif__esp-dsp/modules/iir/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/fir/include espressif__esp-dsp/modules/math/include espressif__esp-dsp/modules/math/add/include espressif__esp-dsp/modules/math/sub/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/math/mul/include espressif__esp-dsp/modules/math/addc/include espressif__esp-dsp/modules/math/mulc/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/math/sqrt/include espressif__esp-dsp/modules/matrix/mul/include espressif__esp-dsp/modules/matrix/add/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/matrix/addc/include espressif__esp-dsp/modules/matrix/mulc/include espressif__esp-dsp/modules/matrix/sub/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/matrix/include espressif__esp-dsp/modules/fft/include espressif__esp-dsp/modules/dct/include espressif__esp-dsp/modules/conv/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/common/include espressif__esp-dsp/modules/matrix/mul/test/include espressif__esp-dsp/modules/kalman/ekf/include
    ESP_INCLUDE_DIRS += espressif__esp-dsp/modules/kalman/ekf_imu13states/include chmorgan__esp-libhelix-mp3/libhelix-mp3/pub espressif__esp-modbus/freemodbus/common/include
    ESP_INCLUDE_DIRS += espressif__libsodium/libsodium/src/libsodium/include espressif__libsodium/port_include espressif__esp_modem/include espressif__esp_schedule/include
    ESP_INCLUDE_DIRS += espressif__network_provisioning/include espressif__esp-serial-flasher/include espressif__esp-serial-flasher/port espressif__esp_rcp_update/include
    ESP_INCLUDE_DIRS += espressif__esp_rainmaker/include espressif__qrcode/include joltwallet__littlefs/include freertos/FreeRTOS-Kernel/include/freertos arduino_tinyusb/tinyusb/src
    ESP_INCLUDE_DIRS += arduino_tinyusb/include fb_gfx/include
endif
endif

ELF_MAP := $(MCU_TARGET).$(MCU_BOARD).map
ESP_DEBUG_LEVEL ?= 0
ESP_MAIN_CORE ?= 1
ESP_EVENT_CORE ?= 1

# CPPFLAGS = compiler options for C and C++
CPPFLAGS ?=
CPPFLAGS += $(OPTIMIZE) $(MCU_OPTIONS) -mlongcalls -MMD -ggdb -gdwarf-4
CPPFLAGS += -ffunction-sections -fdata-sections -freorder-blocks -fstack-protector -fstrict-volatile-bitfields -fno-jump-tables -fno-tree-switch-conversion -fno-lto -Wwrite-strings
CPPFLAGS += -Wall -Wno-error=deprecated-declarations -Wno-unused-parameter  -Wno-error=narrowing -Wno-error=unused-function -Wno-error=unused-variable -Wno-error=unused-but-set-variable
CPPFLAGS += -DARDUINO_ARCH_ESP32 -DESP_PLATFORM -DHAVE_CONFIG_H -DUNITY_INCLUDE_CONFIG_H -D_GNU_SOURCE -DWITH_POSIX -D_POSIX_READER_WRITER_LOCKS -DARDUINO_PARTITION_default -Wno-sign-compare
CPPFLAGS += -DARDUINO_USB_CDC_ON_BOOT=1 -DARDUINO_USB_MSC_ON_BOOT=0 -DARDUINO_USB_DFU_ON_BOOT=0 -DARDUINO_USB_MODE=1 "-DMBEDTLS_CONFIG_FILE=\"mbedtls\/esp_config\.h\""
CPPFLAGS += -DIDF_VER=\"v5.3.2-282-gcfea4f7c98-dirty\" -DCORE_DEBUG_LEVEL=$(ESP_DEBUG_LEVEL) -DARDUINO_RUNNING_CORE=$(ESP_MAIN_CORE) -DARDUINO_EVENT_RUNNING_CORE=$(ESP_EVENT_CORE)
CPPFLAGS += -DESP32 -DCHIP_HAVE_CONFIG_H -DESP32_ARDUINO_LIB_BUILDER -DMD5_ENABLED=1 -DSERIAL_FLASHER_BOOT_HOLD_TIME_MS=50 -DSERIAL_FLASHER_RESET_HOLD_TIME_MS=100
CPPFLAGS += -DSOC_MMU_PAGE_SIZE=CONFIG_MMU_PAGE_SIZE -DSOC_XTAL_FREQ_MHZ=CONFIG_XTAL_FREQ -D_GLIBCXX_HAVE_POSIX_SEMAPHORE -D_GLIBCXX_USE_POSIX_SEMAPHORE -DTF_LITE_STATIC_MEMORY
CPPFLAGS += -DCHIP_CONFIG_SOFTWARE_VERSION_NUMBER=0 -DCHIP_MINMDNS_DEFAULT_POLICY=1 -DCHIP_MINMDNS_USE_EPHEMERAL_UNICAST_PORT=0 -DCHIP_MINMDNS_HIGH_VERBOSITY=0 -DCHIP_DNSSD_DEFAULT_MINIMAL=1
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
ASMFLAGS += x assembler-with-cpp

# compiler options for C only
CFLAGS ?=
ARFLAGS := -rcsT

# additional libraries to link
ifneq ($(strip $(ESP_BUILD_MINIMAL)),yes)
ifeq ($(strip $(ESP_SDK_VERSION)),2)
	ESP_LD_LIBRARIES := esp_ringbuf efuse esp_ipc driver esp_pm mbedtls app_update bootloader_support spi_flash nvs_flash pthread esp_gdbstub espcoredump esp_phy esp_system esp_rom hal vfs
	ESP_LD_LIBRARIES += esp_eth tcpip_adapter esp_netif esp_event  esp_wifi console lwip log heap soc esp_hw_support xtensa esp_common esp_timer freertos newlib cxx app_trace mdns sdmmc
	ESP_LD_LIBRARIES += asio bt cbor unity cmock coap nghttp esp-tls esp_adc_cal esp_hid tcp_transport esp_http_client esp_http_server esp_https_ota esp_https_server esp_lcd protobuf-c
	ESP_LD_LIBRARIES += protocomm esp_local_ctrl  esp_serial_slave_link  expat wear_levelling  freemodbus jsmn json libsodium mqtt openssl perfmon spiffs esp_websocket_client fatfs fb_gfx
	ESP_LD_LIBRARIES += usb ulp wifi_provisioning rmaker_common json_parser json_generator esp_schedule esp_rainmaker gpio_button qrcode  esp_diagnostics rtc_store esp_insights
	ESP_LD_LIBRARIES += esp_littlefs  btdm_app arduino_tinyusb    mfn dl mbedtls_2 mbedcrypto mbedx509 coexist espnow mesh ws2812_led esp32-camera cat_face_detect
	ESP_LD_LIBRARIES += net80211 pp smartconfig wapi phy btbb xt_hal gcc human_face_detect color_detect core
	ESP_LD_LIBRARIES += espressif__esp-dsp espressif__esp_secure_cert_mgr gcov
	# This seems to be baked into multiple places, so we can skip it
    #ESP_LD_LIBRARIES += wpa_supplicant
    # These are missing from the list of default-included libraries, they might need replacements
    #ESP_LD_LIBRARIES += esp-dsp esp-sr esp_audio_front_end esp_audio_processor multinet wakenet hufzip dl_lib c_speech_features esp_tts_chinese voice_set_xiaole
    # Old 2.0.7 includes
	#ESP_LD_LIBRARIES := esp_ringbuf efuse esp_ipc driver esp_pm mbedtls app_update bootloader_support spi_flash nvs_flash pthread esp_gdbstub espcoredump esp_phy esp_system esp_rom hal vfs
    #ESP_LD_LIBRARIES += esp_eth tcpip_adapter esp_netif esp_event wpa_supplicant esp_wifi console lwip log heap soc esp_hw_support xtensa esp_common esp_timer freertos newlib cxx app_trace
    #ESP_LD_LIBRARIES += asio bt cbor unity cmock coap nghttp esp-tls esp_adc_cal esp_hid tcp_transport esp_http_client esp_http_server esp_https_ota esp_https_server esp_lcd protobuf-c
    #ESP_LD_LIBRARIES += protocomm mdns esp_local_ctrl sdmmc esp_serial_slave_link esp_websocket_client expat wear_levelling fatfs freemodbus jsmn json libsodium mqtt openssl perfmon spiffs
    #ESP_LD_LIBRARIES += usb ulp wifi_provisioning rmaker_common json_parser json_generator esp_schedule esp_rainmaker gpio_button qrcode ws2812_led esp_diagnostics rtc_store esp_insights
    #ESP_LD_LIBRARIES += esp32-camera esp_littlefs fb_gfx btdm_app arduino_tinyusb cat_face_detect human_face_detect color_detect mfn dl mbedtls_2 mbedcrypto mbedx509 coexist espnow mesh
    #ESP_LD_LIBRARIES += net80211 pp smartconfig wapi phy btbb xt_hal gcc gcov c
    #ESP_LD_LIBRARIES += esp-dsp esp-sr esp_audio_front_end esp_audio_processor multinet wakenet hufzip dl_lib c_speech_features esp_tts_chinese voice_set_xiaole
    ESP_LD_LIBRARY_SEARCH_DIRS := lib ld qio_qspi
    ESP_LD_LIBRARY_DEFS := memory.ld sections.ld $(MCU).rom.ld $(MCU).rom.api.ld $(MCU).rom.libgcc.ld $(MCU).rom.newlib.ld $(MCU).rom.version.ld $(MCU).rom.newlib-time.ld $(MCU).peripherals.ld
else
    ESP_LD_LIBRARIES := app_trace app_update arduino_tinyusb ble_mesh bootloader_support bt btbb btdm_app c_speech_features chmorgan__esp-libhelix-mp3 cmock coexist console core
    ESP_LD_LIBRARIES += cxx dl_lib driver efuse esp-tls esp_adc esp_app_format esp_audio_front_end esp_audio_processor esp_bootloader_format esp_coex esp_common esp_driver_cam
    ESP_LD_LIBRARIES += esp_driver_gpio esp_driver_gptimer esp_driver_i2c esp_driver_i2s esp_driver_ledc esp_driver_mcpwm esp_driver_pcnt esp_driver_rmt esp_driver_sdm_2
    ESP_LD_LIBRARIES += esp_driver_sdspi esp_driver_spi esp_driver_tsens esp_driver_uart esp_driver_usb_serial_jtag esp_eth esp_event esp_gdbstub esp_hid esp_http_client esp_http_server
    ESP_LD_LIBRARIES += esp_https_ota esp_https_server esp_hw_support esp_lcd esp_local_ctrl esp_mm esp_netif esp_partition esp_phy esp_pm esp_psram esp_ringbuf esp_rom esp_system
    ESP_LD_LIBRARIES += esp_timer esp_tts_chinese esp_vfs_console esp_wifi espcoredump espnow espressif__cbor espressif__esp-dsp espressif__esp-modbus espressif__esp-nn
    ESP_LD_LIBRARIES += espressif__esp-serial-flasher espressif__esp-sr espressif__esp-tflite-micro espressif__esp32-camera espressif__esp_diag_data_store espressif__esp_diagnostics
    ESP_LD_LIBRARIES += espressif__esp_encrypted_img espressif__esp_insights espressif__esp_matter espressif__esp_modem espressif__esp_rainmaker espressif__esp_rcp_update
    ESP_LD_LIBRARIES += espressif__esp_schedule espressif__esp_secure_cert_mgr espressif__json_generator espressif__json_parser espressif__libsodium espressif__mdns esp_driver_sdmmc
    ESP_LD_LIBRARIES += espressif__network_provisioning espressif__qrcode espressif__rmaker_common everest fatfs fb_gfx flite_g2p freertos fst gcc hal heap http_parser
    ESP_LD_LIBRARIES += hufzip joltwallet__littlefs json log lwip m mbedcrypto mbedtls mbedtls_2 mbedx509 mesh mqtt multinet net80211 newlib nsnet nvs_flash nvs_sec_provider
    ESP_LD_LIBRARIES += p256m perfmon phy pp protobuf-c protocomm pthread sdmmc smartconfig soc spi_flash spiffs tcp_transport touch_element ulp unity usb vfs voice_set_xiaole
    ESP_LD_LIBRARIES += wakenet wapi wear_levelling wifi_provisioning wpa_supplicant xt_hal xtensa
    ESP_LD_LIBRARY_SEARCH_DIRS := lib ld qio_qspi
    ESP_LD_LIBRARY_DEFS := memory.ld  sections.ld $(MCU).rom.ld $(MCU).rom.api.ld $(MCU).rom.libgcc.ld $(MCU).rom.newlib.ld $(MCU).rom.version.ld $(MCU).peripherals.ld $(MCU).rom.bt_funcs.ld $(MCU).rom.wdt.ld
endif
endif

# linker options
# 3.1.1 symbols
#ESP_LD_SYMBOLS := _Z5setupv _Z4loopv esp_app_desc pthread_include_pthread_impl pthread_include_pthread_cond_var_impl pthread_include_pthread_local_storage_impl
#ESP_LD_SYMBOLS += pthread_include_pthread_rwlock_impl include_esp_phy_override ld_include_highint_hdl start_app start_app_other_cores __ubsan_include
#ESP_LD_SYMBOLS += __assert_func vfs_include_syscalls_impl  app_main  newlib_include_heap_impl  newlib_include_syscalls_impl  newlib_include_pthread_impl
#ESP_LD_SYMBOLS += newlib_include_assert_impl __cxa_guard_dummy
ESP_LD_SYMBOLS := _Z5setupv _Z4loopv esp_app_desc pthread_include_pthread_impl pthread_include_pthread_cond_var_impl pthread_include_pthread_local_storage_impl pthread_include_pthread_rwlock_impl
ESP_LD_SYMBOLS += include_esp_phy_override ld_include_highint_hdl start_app start_app_other_cores __ubsan_include __assert_func vfs_include_syscalls_impl app_main newlib_include_heap_impl
ESP_LD_SYMBOLS += newlib_include_syscalls_impl newlib_include_pthread_impl newlib_include_assert_impl __cxa_guard_dummy
# 2.0.7 symbols
#ESP_LD_SYMBOLS := _Z5setupv _Z4loopv esp_app_desc pthread_include_pthread_impl pthread_include_pthread_cond_impl pthread_include_pthread_local_storage_impl pthread_include_pthread_rwlock_impl
#ESP_LD_SYMBOLS += include_esp_phy_override ld_include_highint_hdl start_app start_app_other_cores __ubsan_include __assert_func vfs_include_syscalls_impl app_main newlib_include_heap_impl
#ESP_LD_SYMBOLS += newlib_include_syscalls_impl newlib_include_pthread_impl newlib_include_assert_impl __cxa_guard_dummy nvs_sec_provider_include_impl esp_efuse_startup_include_func
#ESP_LD_SYMBOLS += esp_system_include_startup_funcs newlib_include_init_funcs pthread_include_pthread_cond_var_impl pthread_include_pthread_semaphore_impl __cxx_init_dummy
#ESP_LD_SYMBOLS += esp_timer_init_include_func uart_vfs_include_dev_init usb_serial_jtag_vfs_include_dev_init usb_serial_jtag_connection_monitor_include esp_vfs_include_console_register
#ESP_LD_UNDEFINED := esp_kiss_fftndr_alloc esp_kiss_fftndri esp_kiss_fftndr FreeRTOS_openocd_params
ESP_LD_OPTIONS := --cref --gc-sections --wrap=esp_log_write --wrap=esp_log_writev --wrap=log_printf --wrap=longjmp --undefined=uxTopUsedPriority --defsym=__rtc_localtime=$(shell date +%s)
ESP_LD_OPTIONS += --defsym=IDF_TARGET_ESP32S3=0 --warn-common --wrap=esp_log_write --wrap=esp_log_writev --wrap=log_printf
LDFLAGS += $(OPTIMIZE) $(ESP_LD_OPTIONS:%=-Wl,%) $(ESP_LD_UNDEFINED:%=-Wl,-u,%) $(ESP_LD_SYMBOLS:%=-u %)
LDFLAGS += -ffunction-sections -fdata-sections -freorder-blocks -fstack-protector -fstrict-volatile-bitfields -fno-jump-tables -fno-tree-switch-conversion -fno-rtti -fno-lto -Wwrite-strings
LDFLAGS += -fno-builtin-memcpy -fno-builtin-memset -fno-builtin-bzero -fno-builtin-stpcpy -fno-builtin-strncpy -fno-use-linker-plugin -gdwarf-4 -ggdb
LDFLAGS += $(ESP_LD_LIBRARY_DEFS:%=-T %)
ifneq ($(strip $(ESP_SDK_VERSION)),2)
LDFLAGS += -mdisable-hardware-atomics --no-warn-rwx-segments
endif

LIBRARY_PATHS += $(ESP_LD_LIBRARY_SEARCH_DIRS:%="$(ESP_SDK_PATH)/$(MCU_TOOLCHAIN)/%")
LIBS += $(ESP_LD_LIBRARIES) $(ESP_LD_LIBRARIES) c m stdc++
