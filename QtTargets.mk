# Extend sources and object files by the Qt files, sources do not contain the generated sources
SOURCES += $(QT_UI_FILES) $(QT_RESOURCES)
OBJS += $(QT_FRAMEWORK_INCLUDES) $(QT_UIC_SOURCES:%.cpp=%.o) $(QT_MOC_SOURCES:%.cpp=%.o) $(QT_RCC_SOURCES:%.cpp=%.o)

# Generate the U files
$(BUILD_DIR)/%.ui.cpp: %.ui
	$(V)$(UIC) -o "$@" "$<"

# Generate the MOC files
$(BUILD_DIR)/%.moc.cpp: %.h
	$(V)$(MOC) -o "$@" "$<"

# Generate the RCC files
$(BUILD_DIR)/%.rcc.cpp: %.qrc
	$(V)$(RCC) -o "$@" "$<"

$(BUILD_DIR)/Frameworks/%.timestamp: $(QT_TOOLCHAIN_PATH)/lib/%.framework/Headers
	@$(MSG) "[FWK]" "$(CPU_TARGET)" "$(subst $(abspath .)/,,$@)"
	@mkdir -p "$(shell dirname "$@")"
	$(V)ln -fs "$<" "$(BUILD_DIR)/Frameworks/$*"
	$(V)touch "$@"

# Clean the build
clean-qt:
	rm -f $(QT_UIC_SOURCES) $(QT_MOC_SOURCES) $(QT_RCC_SOURCES) $(QT_FRAMEWORK_INCLUDES) $(QT_FRAMEWORK_INCLUDES:%.timestamp=%)

.PHONY: clean-qt