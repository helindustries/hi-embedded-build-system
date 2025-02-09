# Generate the U files
$(BUILD_DIR)/%.ui.cpp: %.ui
	$(UIC) -o $@ $<

# Generate the MOC files
$(BUILD_DIR)/%.moc.cpp: %.h
	$(MOC) -o $@ $<

# Generate the RCC files
$(BUILD_DIR)/%.rcc.cpp: %.qrc
	$(RCC) -o $@ $<

$(BUILD_DIR)/Frameworks/%.timestamp: $(QT_TOOLCHAIN_PATH)/lib/%.framework/Headers
	@$(MSG) "[FWK]" "$(MCU_TARGET)" "$(subst $(abspath .)/,,$@)"
	@mkdir -p "$(shell dirname "$@")"
	$(V)ln -fs $< "$(BUILD_DIR)/Frameworks/$*"
	$(V)touch "$@"

# Clean the build
clean-qt:
	rm -f $(QT_UIC_SOURCES) $(QT_MOC_SOURCES) $(QT_RCC_SOURCES) $(QT_FRAMEWORK_INCLUDES) $(QT_FRAMEWORK_INCLUDES:%.timestamp=%)

.PHONY: build-qt clean-qt