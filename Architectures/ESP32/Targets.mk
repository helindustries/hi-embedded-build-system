CPPFLAGS += $(INCLUDE_PATHS:%=-I%)
LIBS := $(LIBS:%=-l%)
LDFLAGS += $(LIBRARY_PATHS:%=-L%)

ifeq ($(strip $(ARDUINO_VARIANT_NAME)),)
    # Require the files to be in a variant subdirectory
    ESP_BOOTLOADER_BIN ?= $(DEVICES_DIR)/$(CPU_DEVICE)/bootloader.bin
    ESP_BOOT_BIN ?= $(DEVICES_DIR)/$(CPU_DEVICE)/boot_app0.bin

    ifeq ($(strip $(CPU_USE_TINYUF2)),yes)
        ESP_TINYUF2_BIN ?= $(DEVICES_DIR)/$(CPU_DEVICE)/tinyuf2.bin
    endif
else
    ifeq ($(strip $(CPU_USE_TINYUF2)),yes)
        ESP_TINYUF2_BIN ?= $(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/tinyuf2.bin
        ifeq ($(call exists,"$(ESP_TINYUF2_BIN)"),)
            ESP_TINYUF2_BIN ?= $(DEVICES_DIR)/$(CPU_DEVICE)/tinyuf2.bin
            ifeq ($(call exists,"$(ESP_TINYUF2_BIN)"),)
                CPU_USE_TINYUF2 := no
            endif
        endif

        ESP_BOOTLOADER_BIN ?= $(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/bootloader-tinyuf2.bin
        ifeq ($(call exists,"$(ESP_BOOTLOADER_BIN)"),)
            ESP_BOOTLOADER_BIN ?= $(DEVICES_DIR)/$(CPU_DEVICE)/bootloader-tinyuf2.bin
            ifeq ($(call exists,"$(ESP_BOOTLOADER_BIN)"),)
                CPU_USE_TINYUF2 := no
            endif
        endif
    endif

    ifeq ($(call exists,"$(ESP_BOOTLOADER_BIN)"),)
        ESP_BOOTLOADER_BIN ?= $(DEVICES_DIR)/$(CPU_DEVICE)/bootloader.bin
        ESP_BOOTLOADER_ELF ?= $(ESP_SDK_PATH)/$(CPU)/bin/bootloader_$(ESP_FLASH_MODE)_$(ESP_FLASH_FREQ).elf
    endif

    ESP_BOOT_BIN ?= $(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/boot_app0.bin
    ifeq ($(call exists,"$(ESP_BOOT_BIN)"),)
        ESP_BOOT_BIN := $(call latest,"$(ESP_BASE_PATH)/tools/partitions/boot_app0.bin"))
        ifeq ($(call exists,"$(ESP_BOOT_BIN)"),)
            ESP_BOOT_BIN := $(DEVICES_DIR)/$(CPU_DEVICE)/boot_app0.bin
        endif
    endif

    ESP_PARTITIONS_CSV_PATH ?= $(DEVICES_DIR)/$(CPU_DEVICE)/$(CPU_TARGET).partitions.csv
    ifeq ($(call exists,"$(ESP_PARTITIONS_CSV_PATH)"),)
        ESP_PARTITIONS_CSV_PATH := $(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/partitions-$(ESP_FLASH_SIZE)-tinyuf2.csv
        ifeq ($(call exists,"$(ESP_PARTITIONS_CSV_PATH)"),)
            ESP_PARTITIONS_CSV_PATH :=
        endif
    endif
endif

ifeq ($(strip $(CPU_USE_TINYUF2)),yes)
	ESP_TINYUF2_OPTS := "$(ESP_TINYUF2_OFFSET)" "$(ESP_TINYUF2_BIN)"
endif

$(BUILD_DIR)/$(CPU_TARGET)-$(CPU).bin: $(BUILD_DIR)/$(CPU_TARGET)-$(CPU)$(CPU_BINARY_EXT)
	@$(MSG) "[BIN]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(ESPTOOL)" --chip $(CPU) elf2image --flash_mode $(ESP_FLASH_MODE) --flash_freq $(ESP_FLASH_FREQ) --flash_size $(ESP_FLASH_SIZE) --elf-sha256-offset $(ESP_ELF_SHA256_OFFSET) -o "$@" "$<" > /dev/null

ifeq ($(strip $(ESP_PARTITIONS_CSV_PATH)),)
$(BUILD_DIR)/%-$(CPU).partitions.bin: $(DEVICES_DIR)/$(CPU_DEVICE)/%.partitions.csv
	@$(MSG) "[PART]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)python3 "$(ESPGENPART_PY)" -q "$<" "$@"
else
$(BUILD_DIR)/%-$(CPU).partitions.bin: $(ESP_PARTITIONS_CSV_PATH)
	@$(MSG) "[PART]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)python3 "$(ESPGENPART_PY)" -q "$<" "$@"
endif

$(ESP_BOOTLOADER_BIN): $(ESP_BOOTLOADER_ELF)
	$(V)"$(ESPTOOL)" --chip "$(CPU)" elf2image --flash_mode $(ESP_FLASH_MODE) --flash_freq $(ESP_FLASH_FREQ) --flash_size $(ESP_FLASH_SIZE) -o "$@" "$<"

ifneq ($(strip $(HAS_UPLOAD_TARGET)),)
    CPU_DEVICE_PORT ?= $(strip $(shell $(MAKE_PLATFORM_UTILS) --exec $(ESP32_PORTS) $(ESPTOOL) $(strip $(USB_PID)) $(strip $(USB_VID)) $(call print,"$(BUILD_DIR)/.last_esp32_port") /dev/cu.usb* \; --first --print))
    ifeq ($(strip $(VERBOSE)),1)
        $(info $(ESP32_PORTS) $(ESPTOOL) $(strip $(USB_PID)) $(strip $(USB_VID)) $(call print,"$(BUILD_DIR)/.last_esp32_port") /dev/cu.usb* | head -n 1)
        $(info Result: $(CPU_DEVICE_PORT))
    endif
    ifeq ($(strip $(CPU_DEVICE_PORT)),)
	    CPU_DEVICE_PORT ?= $(strip $(shell $(MAKE_PLATFORM_UTILS) --exec $(ESP32_PORTS) $(ESPTOOL) $(strip $(USB_PROG_PID)) $(strip $(USB_VID)) $(call print,"$(BUILD_DIR)/.last_esp32_port") /dev/cu.usb* \; --first --print))
        ifeq ($(strip $(VERBOSE)),1)
            $(info $(ESP32_PORTS) $(ESPTOOL) $(strip $(USB_PID)) $(strip $(USB_VID)) $(call print,"$(BUILD_DIR)/.last_esp32_port") /dev/cu.usb* | head -n 1)
            $(info Result: $(CPU_DEVICE_PORT))
        endif
    endif
endif

ifeq ($(strip $(FORCE_CPU_UPLOAD)),yes)
ESP_CREATE_TIMESTAMP =
upload_$(CPU_TOOLCHAIN): $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).bin $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).partitions.bin $(ESP_BOOTLOADER_BIN) $(ESP_BOOT_BIN) $(ESP_TINYUF2_BIN) resetter
else
ESP_CREATE_TIMESTAMP = && $(TOUCH) "$@"
upload_$(CPU_TOOLCHAIN): $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).bin.upload_$(CPU_TOOLCHAIN).timestamp

%.bin.upload_$(CPU_TOOLCHAIN).timestamp: %.bin %.partitions.bin $(ESP_BOOTLOADER_BIN) $(ESP_BOOT_BIN) $(ESP_TINYUF2_BIN) resetter
endif
ifeq ($(strip $(CPU_WAIT_FOR_BOARD_PORT)),yes)
	@$(FMSG) "INFO:Wait for serial on $(CPU_DEVICE_PORT)"
	@$(MSG) "[SERIAL]" "$(CPU_TARGET)" "$(CPU_DEVICE_PORT)"
ifeq ($(strip $(CPU_DEVICE_PORT)),)
	$(V)$(FAIL)
else
	$(V)$(PYTHON) "$(MAKE_INC_PATH)/wait_for_device.py" "$(CPU_DEVICE_PORT)"
endif
endif
ifneq ($(strip $(NO_FIRMWARE_UPLOAD)),yes)
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$<)"
ifneq ($(strip $(CPU_PASSTHROUGH_BIN)),)
	# In case the CPU requires the FPGA to be loaded with a bitstream before uploading to the CPU
	$(V)"$(OPENOCD)" $(OPENOCD_DEBUG) -s "$(OPENOCD_CFG_DIR)" -f "$(OPENOCD_CFG_DIR)/$(FPGA_DEBUG_ADAPTER).cfg" -f "$(MAKE_INC_PATH)/Devices/FPGA/$(FPGA_DEVICE).ocd.cfg" -c "init" -c "scan_chain" -c "svf $(CPU_PASSTHROUGH_BIN) -ignore_error" -c "shutdown"
endif
	$(V)"$(ESPTOOL)" --chip "$(CPU)" --port "$(CPU_DEVICE_PORT)" --baud "$(CPU_DEVICE_RATE)" --before default_reset --after hard_reset write_flash -z \
			--flash_mode "$(ESP_FLASH_MODE)" --flash_freq "$(ESP_FLASH_FREQ)" --flash_size "$(ESP_FLASH_SIZE)" \
			"0x0" "$(ESP_BOOTLOADER_BIN)" "$(ESP_PARTITION_OFFSET)" "$(BUILD_DIR)/$(CPU_TARGET)-$(CPU).partitions.bin" "$(ESP_BOOT_OFFSET)" "$(ESP_BOOT_BIN)" "$(ESP_BIN_OFFSET)" "$(BUILD_DIR)/$(CPU_TARGET)-$(CPU).bin" \
			$(ESP_TINYUF2_OPTS) && $(call write,"$(CPU_DEVICE_PORT)","$(BUILD_DIR)/.last_esp32_port") $(ESP_CREATE_TIMESTAMP)
endif

ifeq ($(strip $(FORCE_CPU_UPLOAD)),yes)
upload_$(CPU_TOOLCHAIN)_jtag: $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).bin $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).partitions.bin
else
upload_$(CPU_TOOLCHAIN)_jtag: $(BUILD_DIR)/$(CPU_TARGET)-$(CPU).bin.upload_$(CPU_TOOLCHAIN)_jtag.timestamp

%.bin.upload_$(CPU_TOOLCHAIN)_jtag.timestamp: %.bin %.partitions.bin
endif
ifneq ($(strip $(NO_FIRMWARE_UPLOAD)), yes)
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)"$(OPENOCD)" $(OPENOCD_DEBUG) -s "$(OPENOCD_CFG_DIR)" -f "$(OPENOCD_CFG_DIR)/$(CPU_DEBUG_ADAPTER).cfg" -f "$(MAKE_INC_PATH)/Devices/CPU/$(CPU_DEVICE).ocd.cfg" -c "program_esp $< $(ESP_BIN_OFFSET) verify reset exit" $(ESP_CREATE_TIMESTAMP)
endif

clean_$(CPU_TOOLCHAIN):
	@$(MSG) "[CLEAN]" "$(CPU_TARGET)" "$(CPU) ESP32"
	$(V)rm -f "$(BUILD_DIR)/$(CPU_TARGET)-$(CPU).bin"
	$(V)rm -f "$(BUILD_DIR)/$(CPU_TARGET)-$(CPU).partitions.bin"

cfg-toolchain:
	@$(MSG) "[CFG]" "$(CPU_TOOLCHAIN)"
	@$(CFGMSG) "ESPTOOL" "$(ESPTOOL)"
	@$(CFGMSG) "ESPGENPART_PY" "$(ESPGENPART_PY)"
	@$(CFGMSG) "ESP_SDK_PATH" "$(ESP_SDK_PATH)"
	@$(CFGMSG) "ESP_FLASH_MODE" "$(ESP_FLASH_MODE)"
	@$(CFGMSG) "ESP_FLASH_FREQ" "$(ESP_FLASH_FREQ)"
	@$(CFGMSG) "ESP_FLASH_SIZE" "$(ESP_FLASH_SIZE)"
	@$(CFGMSG) "ESP_BOOTLOADER_ELF" "$(ESP_BOOTLOADER_ELF)"
	@$(CFGMSG) "ESP_BOOTLOADER_BIN" "$(ESP_BOOTLOADER_BIN)"
	@$(CFGMSG) "ESP_PARTITION_OFFSET" "$(ESP_PARTITION_OFFSET)"
	@$(CFGMSG) "ESP_BOOT_OFFSET" "$(ESP_BOOT_OFFSET)"
	@$(CFGMSG) "ESP_BOOT_BIN" "$(ESP_BOOT_BIN)"
	@$(CFGMSG) "ESP_BIN_OFFSET" "$(ESP_BIN_OFFSET)"
	@$(CFGMSG) "CPU_USE_TINYUF2" "$(CPU_USE_TINYUF2)"
	@$(CFGMSG) "ESP_TINYUF2_OFFSET" "$(ESP_TINYUF2_OFFSET)"
	@$(CFGMSG) "ESP_TINYUF2_BIN" "$(ESP_TINYUF2_BIN)"

.PHONY: cfg-toolchain clean_$(CPU_TOOLCHAIN) upload_$(CPU_TOOLCHAIN) upload_$(CPU_TOOLCHAIN)_jtag
