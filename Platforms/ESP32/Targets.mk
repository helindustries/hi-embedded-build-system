MODULES_LIBS := $(MODULES_NAMES:%=$(BUILD_DIR)/lib%.a)
CPPFLAGS += -I$(abspath .) -I$(abspath $(MCU_BOARD)) -I$(CORE_PATH)
CPPFLAGS += $(MODULES_PATHS:%=-I%) $(MODULES_PATHS:%=-I%/src) $(MODULES_PATHS:%=-I%/Source)
CPPFLAGS += $(DEPENDENCY_INCLUDE_PATHS:%=-I%) $(DEPENDENCY_INCLUDE_PATHS:%=-I%/src) $(DEPENDENCY_INCLUDE_PATHS:%=-I%/Source)

ESP_PARTITION_OFFSET ?= 0x8000
ESP_BOOT_OFFSET ?= 0xe000
ESP_BIN_OFFSET ?= 0x10000
ESP_TINYUF2_OFFSET ?= 0x2d0000

ifneq ($(strip $(ARDUINO_VARIANT_PATH)),)
	# Require the files to be in a variant subdirectory
	ESP_BOOTLOADER_BIN ?= $(MCU_BOARD)/bootloader.bin
	ESP_BOOT_BIN ?= $(MCU_BOARD)/boot_app0.bin

	ifeq ($(strip $(MCU_USE_TINYUF2)),yes)
		ESP_TINYUF2_BIN ?= $(MCU_BOARD)/tinyuf2.bin
	endif
else
	# Use the files from the variant Arduino variant path, fall back to default data if necessary. In case of the
	# bootloader, this is the one in the SDK, for the boot_app0 binary, there is a default in the Arduino install,
	# for TinyUF2, if it isn't in the variant or the board-specific project path, don't use it
	ESP_BOOTLOADER_BIN ?= $(strip $(shell $(LS) "$(ARDUINO_VARIANT_PATH)/bootloader"*".bin" 2>/dev/null | sort | tail -n 1))
	ifeq ($(strip $(shell $(LS) $(ESP_BOOTLOADER_BIN) 2>/dev/null)),)
		ESP_BOOTLOADER_BIN ?= $(MCU_BOARD)/bootloader.bin
		ESP_BOOTLOADER_ELF ?= $(strip $(shell $(LS) "$(ARDUINO_USERPATH)/packages/esp32/hardware/esp32/"*"/tools/sdk/$(MCU)/bin/bootloader_$(ESP_FLASH_MODE)_$(ESP_FLASH_FREQ).elf" 2>/dev/null | sort | tail -n 1))
	endif

	ESP_BOOT_BIN ?= $(ARDUINO_VARIANT_PATH)/boot_app0.bin
	ifeq ($(strip $(shell $(LS) $(ESP_BOOT_BIN) 2>/dev/null)),)
		ESP_BOOT_BIN ?= $(strip $(shell $(LS) "$(ARDUINO_USERPATH)/packages/esp32/hardware/esp32/"*"/tools/partitions/boot_app0.bin" 2>/dev/null | sort | tail -n 1))
		ifeq ($(strip $(shell $(LS) $(ESP_BOOT_BIN) 2>/dev/null)),)
			ESP_BOOT_BIN ?= $(MCU_BOARD)/boot_app0.bin
		endif
	endif

	ifeq ($(strip $(MCU_USE_TINYUF2)),yes)
	ESP_TINYUF2_BIN ?= $(ARDUINO_VARIANT_PATH)/tinyuf2.bin
		ifeq ($(strip $(shell $(LS) $(ESP_TINYUF2_BIN) 2>/dev/null)),)
			ESP_TINYUF2_BIN ?= $(MCU_BOARD)/tinyuf2.bin
			ifeq ($(strip $(shell $(LS) $(ESP_TINYUF2_BIN) 2>/dev/null)),)
				MCU_USE_TINYUF2 := no
			endif
		endif
	endif
endif

ifeq ($(strip $(MCU_USE_TINYUF2)),yes)
	ESP_TINYUF2_OPTS := "$(ESP_TINYUF2_OFFSET)" "$(ESP_TINYUF2_BIN)"
endif

$(BUILD_DIR)/$(MCU_TARGET)-$(MCU).bin: $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).elf
	@$(MSG) "[BIN]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)"$(ESPTOOL)" --chip $(MCU) elf2image --flash_mode $(ESP_FLASH_MODE) --flash_freq $(ESP_FLASH_FREQ) --flash_size $(ESP_FLASH_SIZE) --elf-sha256-offset $(ESP_FLASH_SHA256_OFFSET) -o "$@" "$<" $(PROCESS_OUTPUT)

$(BUILD_DIR)/%-$(MCU).partitions.bin: $(MCU_BOARD)/%.partitions.csv
	@$(MSG) "[PART]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	$(V)python3 "$(ESPGENPART_PY)" -q "$<" "$@" $(PROCESS_OUTPUT)

$(ESP_BOOTLOADER_BIN): $(ESP_BOOTLOADER_ELF)
	$(V)"$(ESPTOOL)" --chip "$(MCU)" elf2image --flash_mode $(ESP_FLASH_MODE) --flash_freq $(ESP_FLASH_FREQ) --flash_size $(ESP_FLASH_SIZE) -o "$@" "$<" $(PROCESS_OUTPUT)

%.bin.upload_$(MCU_TOOLCHAIN).timestamp: %.bin %.partitions.bin $(ESP_BOOTLOADER_BIN) $(ESP_BOOT_BIN) $(ESP_TINYUF2_BIN) resetter
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$<)"
ifneq ($(strip $(MCU_PASSTHROUGH_BIN)),)
	# In case the MCU requires the FPGA to be loaded with a bitstream before uploading to the MCU
	$(V)"$(OPENOCD)" $(OPENOCD_DEBUG) -s "$(OPENOCD_CFG_DIR)" -f "$(OPENOCD_CFG_DIR)/$(FPGA_DEBUG_ADAPTER).cfg" -f "$(MAKE_INC_PATH)/Targets/FPGA/$(FPGA_BOARD).ocd.cfg" -c "init" -c "scan_chain" -c "svf $(MCU_PASSTHROUGH_BIN) -ignore_error" -c "shutdown" $(PROCESS_OUTPUT)
endif
	$(V)"$(ESPTOOL)" --chip "$(MCU)" --port "$(MCU_BOARD_PORT)" --baud "$(MCU_BOARD_RATE)" --before default_reset --after hard_reset write_flash -z --flash_mode "$(ESP_FLASH_MODE)" --flash_freq "$(ESP_FLASH_FREQ)" --flash_size "$(ESP_FLASH_SIZE)" \
			"0x0" "$(ESP_BOOTLOADER_BIN)" "$(ESP_PARTITION_OFFSET)" "$(BUILD_DIR)/$(MCU_TARGET)-$(MCU).partitions.bin" "$(ESP_BOOT_OFFSET)" "$(ESP_BOOT_BIN)" "$(ESP_BIN_OFFSET)" "$(BUILD_DIR)/$(MCU_TARGET)-$(MCU).bin" \
			"$(ESP_TINYUF2_OPTS)" $(PROCESS_OUTPUT) && echo "$(MCU_BOARD_PORT)" > "$(BUILD_DIR)/.last_esp32_port"
	$(V)touch "$@"

upload_$(MCU_TOOLCHAIN): $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).bin.upload_$(MCU_TOOLCHAIN).timestamp

%.bin.upload_$(MCU_TOOLCHAIN)_jtag.timestamp: %.bin %.partitions.bin
ifneq ($(strip $(MCU_JTAG_UPLOAD_BY_IDE)), yes)
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)"$(OPENOCD)" $(OPENOCD_DEBUG) -s "$(OPENOCD_CFG_DIR)" -f "$(OPENOCD_CFG_DIR)/$(MCU_DEBUG_ADAPTER).cfg" -f "$(MAKE_INC_PATH)/Targets/MCU/$(MCU_BOARD).ocd.cfg" -c "program_esp $< $(ESP_BIN_OFFSET) verify reset exit" $(PROCESS_OUTPUT)
	$(V)touch "$@"
endif

upload_$(MCU_TOOLCHAIN)_jtag: $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).bin.upload_$(MCU_TOOLCHAIN)_jtag.timestamp

clean_$(MCU_TOOLCHAIN):
	$(V)rm -f "$(BUILD_DIR)/$(MCU_TARGET)-$(MCU).bin"
	$(V)rm -f "$(BUILD_DIR)/$(MCU_TARGET)-$(MCU).partitions.bin"
