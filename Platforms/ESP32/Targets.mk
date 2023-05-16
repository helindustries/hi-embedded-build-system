MODULES_LIBS := $(MODULES_NAMES:%=$(BUILD_DIR)/lib%.a)
CPPFLAGS += -I$(abspath .) -I$(abspath $(MCU_BOARD)) -I$(CORE_PATH)
CPPFLAGS += $(MODULES_PATHS:%=-I%) $(MODULES_PATHS:%=-I%/src) $(MODULES_PATHS:%=-I%/Source)
CPPFLAGS += $(DEPENDENCY_INCLUDE_PATHS:%=-I%) $(DEPENDENCY_INCLUDE_PATHS:%=-I%/src) $(DEPENDENCY_INCLUDE_PATHS:%=-I%/Source)

ESP_PARTITION_OFFSET ?= 0x8000
ESP_BOOT_OFFSET ?= 0xe000
ESP_BIN_OFFSET ?= 0x10000
ESP_TINYUF2_OFFSET ?= 0x2d0000

ifeq ($(strip $(ARDUINO_VARIANT_NAME)),)
	# Require the files to be in a variant subdirectory
	ESP_BOOTLOADER_BIN ?= $(MCU_BOARD)/bootloader.bin
	ESP_BOOT_BIN ?= $(MCU_BOARD)/boot_app0.bin

	ifeq ($(strip $(MCU_USE_TINYUF2)),yes)
		ESP_TINYUF2_BIN ?= $(MCU_BOARD)/tinyuf2.bin
	endif
else
	ifeq ($(strip $(MCU_USE_TINYUF2)),yes)
		ESP_TINYUF2_BIN ?= $(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/tinyuf2.bin
		ifeq ($(strip $(shell $(LS) "$(ESP_TINYUF2_BIN)" 2>/dev/null)),)
			ESP_TINYUF2_BIN ?= $(MCU_BOARD)/tinyuf2.bin
			ifeq ($(strip $(shell $(LS) "$(ESP_TINYUF2_BIN)" 2>/dev/null)),)
				MCU_USE_TINYUF2 := no
			endif
		endif

		ESP_BOOTLOADER_BIN ?= $(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/bootloader-tinyuf2.bin
		ifeq ($(strip $(shell $(LS) "$(ESP_BOOTLOADER_BIN)" 2>/dev/null)),)
			ESP_BOOTLOADER_BIN ?= $(MCU_BOARD)/bootloader-tinyuf2.bin
			ifeq ($(strip $(shell $(LS) "$(ESP_BOOTLOADER_BIN)" 2>/dev/null)),)
				MCU_USE_TINYUF2 := no
			endif
		endif
	endif

	ifeq ($(strip $(shell $(LS) "$(ESP_BOOTLOADER_BIN)" 2>/dev/null)),)
		ESP_BOOTLOADER_BIN ?= $(MCU_BOARD)/bootloader.bin
		ESP_BOOTLOADER_ELF ?= $(ESP_SDK_PATH)/$(MCU)/bin/bootloader_$(ESP_FLASH_MODE)_$(ESP_FLASH_FREQ).elf
	endif

	ESP_BOOT_BIN ?= $(CORE_VARIANTS_PATH)/$(ARDUINO_VARIANT_NAME)/boot_app0.bin
	ifeq ($(strip $(shell $(LS) "$(ESP_BOOT_BIN)" 2>/dev/null)),)
		ESP_BOOT_BIN ?= $(strip $(shell $(LS) "$(ESP_BASE_PATH)/tools/partitions/boot_app0.bin" 2>/dev/null | sort | tail -n 1))
		ifeq ($(strip $(shell $(LS) "$(ESP_BOOT_BIN)" 2>/dev/null)),)
			ESP_BOOT_BIN ?= $(MCU_BOARD)/boot_app0.bin
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
	$(V)set -o pipefail && "$(OPENOCD)" $(OPENOCD_DEBUG) -s "$(OPENOCD_CFG_DIR)" -f "$(OPENOCD_CFG_DIR)/$(FPGA_DEBUG_ADAPTER).cfg" -f "$(MAKE_INC_PATH)/Targets/FPGA/$(FPGA_BOARD).ocd.cfg" -c "init" -c "scan_chain" -c "svf $(MCU_PASSTHROUGH_BIN) -ignore_error" -c "shutdown" $(PROCESS_OUTPUT)
endif
	$(V)set -o pipefail && "$(ESPTOOL)" --chip "$(MCU)" --port "$(MCU_BOARD_PORT)" --baud "$(MCU_BOARD_RATE)" --before default_reset --after hard_reset write_flash -z \
			--flash_mode "$(ESP_FLASH_MODE)" --flash_freq "$(ESP_FLASH_FREQ)" --flash_size "$(ESP_FLASH_SIZE)" \
			"0x0" "$(ESP_BOOTLOADER_BIN)" "$(ESP_PARTITION_OFFSET)" "$(BUILD_DIR)/$(MCU_TARGET)-$(MCU).partitions.bin" "$(ESP_BOOT_OFFSET)" "$(ESP_BOOT_BIN)" "$(ESP_BIN_OFFSET)" "$(BUILD_DIR)/$(MCU_TARGET)-$(MCU).bin" \
			"$(ESP_TINYUF2_OPTS)" $(PROCESS_OUTPUT) && echo "$(MCU_BOARD_PORT)" > "$(BUILD_DIR)/.last_esp32_port" && touch "$@"

upload_$(MCU_TOOLCHAIN): $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).bin.upload_$(MCU_TOOLCHAIN).timestamp

%.bin.upload_$(MCU_TOOLCHAIN)_jtag.timestamp: %.bin %.partitions.bin
ifneq ($(strip $(MCU_JTAG_UPLOAD_BY_IDE)), yes)
	@$(FMSG) "INFO:Uploading $<"
	@$(MSG) "[UPLOAD]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$<)"
	$(V)set -o pipefail && "$(OPENOCD)" $(OPENOCD_DEBUG) -s "$(OPENOCD_CFG_DIR)" -f "$(OPENOCD_CFG_DIR)/$(MCU_DEBUG_ADAPTER).cfg" -f "$(MAKE_INC_PATH)/Targets/MCU/$(MCU_BOARD).ocd.cfg" -c "program_esp $< $(ESP_BIN_OFFSET) verify reset exit" $(PROCESS_OUTPUT) && touch "$@"
endif

upload_$(MCU_TOOLCHAIN)_jtag: $(BUILD_DIR)/$(MCU_TARGET)-$(MCU).bin.upload_$(MCU_TOOLCHAIN)_jtag.timestamp

clean_$(MCU_TOOLCHAIN):
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
