CPPFLAGS += $(INCLUDE_PATHS:%=-I%)
LDFLAGS += $(LIBRARY_PATHS:%=-L%)
LIBS := $(LIBS:%=-l%)

ifeq ($(strip $(ARDUINO_VARIANT_NAME)),)
    # Require the files to be in a variant subdirectory
    ESP_BOOTLOADER_BIN ?= $(BOARDS_DIR)/$(MCU_BOARD)/bootloader.bin
    ESP_BOOT_BIN ?= $(BOARDS_DIR)/$(MCU_BOARD)/boot_app0.bin

    ifeq ($(strip $(MCU_USE_TINYUF2)),yes)
        ESP_TINYUF2_BIN ?= $(BOARDS_DIR)/$(MCU_BOARD)/tinyuf2.bin
    endif
else
    ifeq ($(strip $(MCU_USE_TINYUF2)),yes)
        ESP_TINYUF2_BIN ?= $(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/tinyuf2.bin
        ifeq ($(strip $(shell ls --color=never "$(ESP_TINYUF2_BIN)" 2>/dev/null)),)
            ESP_TINYUF2_BIN ?= $(BOARDS_DIR)/$(MCU_BOARD)/tinyuf2.bin
            ifeq ($(strip $(shell ls --color=never "$(ESP_TINYUF2_BIN)" 2>/dev/null)),)
                MCU_USE_TINYUF2 := no
            endif
        endif

        ESP_BOOTLOADER_BIN ?= $(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/bootloader-tinyuf2.bin
        ifeq ($(strip $(shell ls --color=never "$(ESP_BOOTLOADER_BIN)" 2>/dev/null)),)
            ESP_BOOTLOADER_BIN ?= $(BOARDS_DIR)/$(MCU_BOARD)/bootloader-tinyuf2.bin
            ifeq ($(strip $(shell ls --color=never "$(ESP_BOOTLOADER_BIN)" 2>/dev/null)),)
                MCU_USE_TINYUF2 := no
            endif
        endif
    endif

    ifeq ($(strip $(shell ls --color=never "$(ESP_BOOTLOADER_BIN)" 2>/dev/null)),)
        ESP_BOOTLOADER_BIN ?= $(BOARDS_DIR)/$(MCU_BOARD)/bootloader.bin
        ESP_BOOTLOADER_ELF ?= $(ESP_SDK_PATH)/$(MCU)/bin/bootloader_$(ESP_FLASH_MODE)_$(ESP_FLASH_FREQ).elf
    endif

    ESP_BOOT_BIN ?= $(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/boot_app0.bin
    ifeq ($(strip $(shell ls --color=never "$(ESP_BOOT_BIN)" 2>/dev/null)),)
        ESP_BOOT_BIN := $(strip $(shell ls --color=never "$(ESP_BASE_PATH)/tools/partitions/boot_app0.bin" 2>/dev/null | sort | tail -n 1))
        ifeq ($(strip $(shell $(LS) "$(ESP_BOOT_BIN)" 2>/dev/null)),)
            ESP_BOOT_BIN := $(BOARDS_DIR)/$(MCU_BOARD)/boot_app0.bin
        endif
    endif

    ESP_PARTITIONS_CSV_PATH ?= $(BOARDS_DIR)/$(MCU_BOARD)/$(MCU_TARGET).partitions.csv
    ifeq ($(strip $(shell ls --color=never $(ESP_PARTITIONS_CSV_PATH) 2>/dev/null)),)
	    ESP_PARTITIONS_CSV_PATH := $(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/partitions-$(ESP_FLASH_SIZE)-tinyuf2.csv
	    ifeq ($(strip $(shell ls --color=never $(ESP_PARTITIONS_CSV_PATH) 2>/dev/null)),)
	    	ESP_PARTITIONS_CSV_PATH :=
		endif
	endif
endif

ifeq ($(strip $(MCU_USE_TINYUF2)),yes)
	ESP_TINYUF2_OPTS := "$(ESP_TINYUF2_OFFSET)" "$(ESP_TINYUF2_BIN)"
endif

$(BUILD_DIR)/$(MCU_TARGET)-$(MCU).bin: $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).elf
	@$(MSG) "[BIN]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(ESPTOOL)" --chip $(MCU) elf2image --flash_mode $(ESP_FLASH_MODE) --flash_freq $(ESP_FLASH_FREQ) --flash_size $(ESP_FLASH_SIZE) --elf-sha256-offset $(ESP_ELF_SHA256_OFFSET) -o "$@" "$<" $(PROCESS_OUTPUT)

ifeq ($(strip $(ESP_PARTITIONS_CSV_PATH)),)
$(BUILD_DIR)/%-$(MCU).partitions.bin: $(BOARDS_DIR)/$(MCU_BOARD)/%.partitions.csv
	@$(MSG) "[PART]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)python3 "$(ESPGENPART_PY)" -q "$<" "$@" $(PROCESS_OUTPUT)
else
$(BUILD_DIR)/%-$(MCU).partitions.bin: $(ESP_PARTITIONS_CSV_PATH)
	@$(MSG) "[PART]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)python3 "$(ESPGENPART_PY)" -q "$<" "$@" $(PROCESS_OUTPUT)
endif

$(ESP_BOOTLOADER_BIN): $(ESP_BOOTLOADER_ELF)
	$(V)"$(ESPTOOL)" --chip "$(MCU)" elf2image --flash_mode $(ESP_FLASH_MODE) --flash_freq $(ESP_FLASH_FREQ) --flash_size $(ESP_FLASH_SIZE) -o "$@" "$<" $(PROCESS_OUTPUT)

MCU_BOARD_PORT ?= $(strip $(shell $(ESP32_PORTS) $(ESPTOOL) $(strip $(USB_PID)) $(strip $(USB_VID)) $(shell cat "$(BUILD_DIR)/.last_esp32_port" 2>/dev/null) /dev/cu.usb* | head -n 1))
ifeq ($(strip $(VERBOSE)),1)
    $(info $(ESP32_PORTS) $(ESPTOOL) $(strip $(USB_PID)) $(strip $(USB_VID)) $(shell cat "$(BUILD_DIR)/.last_esp32_port" 2>/dev/null) /dev/cu.usb* | head -n 1)
    $(info Result: $(MCU_BOARD_PORT))
endif
ifeq ($(strip $(MCU_BOARD_PORT)),)
    MCU_BOARD_PORT ?= $(strip $(shell $(ESP32_PORTS) $(ESPTOOL) $(strip $(USB_PROG_PID)) $(strip $(USB_VID)) $(shell cat "$(BUILD_DIR)/.last_esp32_port" 2>/dev/null) /dev/cu.usb* | head -n 1))
    ifeq ($(strip $(VERBOSE)),1)
        $(info $(ESP32_PORTS) $(ESPTOOL) $(strip $(USB_PID)) $(strip $(USB_VID)) $(shell cat "$(BUILD_DIR)/.last_esp32_port" 2>/dev/null) /dev/cu.usb* | head -n 1)
        $(info Result: $(MCU_BOARD_PORT))
    endif
endif

ifeq ($(strip $(FORCE_MCU_UPLOAD)),yes)
ESP_CREATE_TIMESTAMP =
upload_$(MCU_TOOLCHAIN): $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).bin $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).partitions.bin $(ESP_BOOTLOADER_BIN) $(ESP_BOOT_BIN) $(ESP_TINYUF2_BIN) resetter
else
ESP_CREATE_TIMESTAMP = && touch "$@"
upload_$(MCU_TOOLCHAIN): $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).bin.upload_$(MCU_TOOLCHAIN).timestamp

%.bin.upload_$(MCU_TOOLCHAIN).timestamp: %.bin %.partitions.bin $(ESP_BOOTLOADER_BIN) $(ESP_BOOT_BIN) $(ESP_TINYUF2_BIN) resetter
endif
ifeq ($(strip $(MCU_WAIT_FOR_BOARD_PORT)),yes)
	@$(FMSG) "INFO:Wait for serial on $(MCU_BOARD_PORT)"
	@$(MSG) "[SERIAL]" "$(MCU_TARGET)" "$(MCU_BOARD_PORT)"
ifeq ($(strip $(MCU_BOARD_PORT)),)
	$(V)false
else
	@while [ ! -e "$(MCU_BOARD_PORT)" ]; do sleep 1; done;
endif
endif
ifneq ($(strip $(NO_FIRMWARE_UPLOAD)),yes)
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$<)"
ifneq ($(strip $(MCU_PASSTHROUGH_BIN)),)
	# In case the MCU requires the FPGA to be loaded with a bitstream before uploading to the MCU
	$(V)set -o pipefail && "$(OPENOCD)" $(OPENOCD_DEBUG) -s "$(OPENOCD_CFG_DIR)" -f "$(OPENOCD_CFG_DIR)/$(FPGA_DEBUG_ADAPTER).cfg" -f "$(MAKE_INC_PATH)/Targets/FPGA/$(FPGA_BOARD).ocd.cfg" -c "init" -c "scan_chain" -c "svf $(MCU_PASSTHROUGH_BIN) -ignore_error" -c "shutdown" $(PROCESS_OUTPUT)
endif
	$(V)"$(ESPTOOL)" --chip "$(MCU)" --port "$(MCU_BOARD_PORT)" --baud "$(MCU_BOARD_RATE)" --before default_reset --after hard_reset write_flash -z \
			--flash_mode "$(ESP_FLASH_MODE)" --flash_freq "$(ESP_FLASH_FREQ)" --flash_size "$(ESP_FLASH_SIZE)" \
			"0x0" "$(ESP_BOOTLOADER_BIN)" "$(ESP_PARTITION_OFFSET)" "$(BUILD_DIR)/$(MCU_TARGET)-$(MCU).partitions.bin" "$(ESP_BOOT_OFFSET)" "$(ESP_BOOT_BIN)" "$(ESP_BIN_OFFSET)" "$(BUILD_DIR)/$(MCU_TARGET)-$(MCU).bin" \
			$(ESP_TINYUF2_OPTS) && echo "$(MCU_BOARD_PORT)" > "$(BUILD_DIR)/.last_esp32_port" $(ESP_CREATE_TIMESTAMP)
			# $(PROCESS_OUTPUT)
endif

ifeq ($(strip $(FORCE_MCU_UPLOAD)),yes)
upload_$(MCU_TOOLCHAIN)_jtag: $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).bin $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).partitions.bin
else
upload_$(MCU_TOOLCHAIN)_jtag: $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).bin.upload_$(MCU_TOOLCHAIN)_jtag.timestamp

%.bin.upload_$(MCU_TOOLCHAIN)_jtag.timestamp: %.bin %.partitions.bin
endif
ifneq ($(strip $(NO_FIRMWARE_UPLOAD)), yes)
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)set -o pipefail && "$(OPENOCD)" $(OPENOCD_DEBUG) -s "$(OPENOCD_CFG_DIR)" -f "$(OPENOCD_CFG_DIR)/$(MCU_DEBUG_ADAPTER).cfg" -f "$(MAKE_INC_PATH)/Targets/MCU/$(MCU_BOARD).ocd.cfg" -c "program_esp $< $(ESP_BIN_OFFSET) verify reset exit" $(PROCESS_OUTPUT) $(ESP_CREATE_TIMESTAMP)
endif

clean_$(MCU_TOOLCHAIN):
	@$(MSG) "[CLEAN]" "$(MCU_TARGET)" "$(MCU) ESP32"
	$(V)rm -f "$(BUILD_DIR)/$(MCU_TARGET)-$(MCU).bin"
	$(V)rm -f "$(BUILD_DIR)/$(MCU_TARGET)-$(MCU).partitions.bin"

cfg-toolchain:
	@$(MSG) "[CFG]" "$(MCU_TOOLCHAIN)"
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
	@$(CFGMSG) "MCU_USE_TINYUF2" "$(MCU_USE_TINYUF2)"
	@$(CFGMSG) "ESP_TINYUF2_OFFSET" "$(ESP_TINYUF2_OFFSET)"
	@$(CFGMSG) "ESP_TINYUF2_BIN" "$(ESP_TINYUF2_BIN)"

.PHONY: cfg-toolchain clean_$(MCU_TOOLCHAIN) upload_$(MCU_TOOLCHAIN) upload_$(MCU_TOOLCHAIN)_jtag
