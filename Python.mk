PYTHON_BUILD_TARGETS := $(patsubst %.py,%.py.build.target,$(PYTHON_FILES))
PYTHON_DOCTEST_TARGETS := $(patsubst %.py,%.py.doctest.target,$(PYTHON_FILES))
PYTHON_PYTEST_TARGETS := $(patsubst %.py,%.py.pytest.target,$(PYTHON_TESTS))
PYTHON_FILES := $(filter-out %_test.py,$(filter-out test_%.py,$(PYTHON_FILES)))

MYPY := $(PYTHON_ENV) $(shell $(WHICH) mypy)
DOCTEST := $(PYTHON) -m doctest
PYTEST := $(PYTHON_ENV) $(shell $(WHICH) pytest)

# Use mypy.ini in the make file directory by default
MYPY_CONFIG_PATH ?= $(wildcard mypy.ini)
MYPY_CONFIG_OPTS :=  --ignore-missing-imports
ifneq ($(strip $(MYPY_CONFIG_PATH)),)
	MYPY_CONFIG_OPTS += --config-file="$(MYPY_CONFIG_PATH)"
endif

ifeq ($(strip $(PYTHON_EXEC_SPEC_FILE)),)
    PYTHON_EXEC_ARGS := $(PYTHON_EXEC_PATHS:%=-p "%") --onefile
endif

build-python: $(PYTHON_BUILD_TARGETS) | silent

test-python: build-python $(PYTHON_DOCTEST_TARGETS) $(PYTHON_PYTEST_TARGETS) | silent

cfg-python: | silent
	@$(MSG) "[CFG]" "Python"
	@$(CFGMSG) "PYTHON_FILES:" "$(PYTHON_FILES)"

%.py.build.target: %.py
	@$(MSG) "[PY]" "$<"
	$(V)$(call process_output,$(MYPY) $(MYPY_CONFIG_OPTS) $< --no-color-output)

%.py.doctest.target: %.py
	@$(MSG) "[TEST]" "$<"
	$(V)$(DOCTEST) $<

%.py.pytest.target: %.py
	@$(MSG) "[TEST]" "$<"
	$(V)$(PYTEST) $<

python-exec: $(PYTHON_TARGET) $(PYTHON_TARGET).py $(PYTHON_FILES) | silent

$(PYTHON_TARGET): $(PYTHON_EXEC_SPEC_FILE) $(PYTHON_TARGET).py $(PYTHON_FILES)
	@$(MSG) "[EXEC]" "$(PYTHON_TARGET)"
	$(V)pyinstaller $(PYTHON_EXEC_ARGS) --log-level ERROR --distpath dist/$(PLATFORM_ID) --workpath $(BUILD_DIR)/$(PYTHON_TARGET).pyinstaller --noconfirm "$<"

clean-python-exec: | silent
	$(V)$(RMDIR) dist $(BUILD_DIR)/$(PYTHON_TARGET).pyinstaller

.PHONY: %.py.build.target %.py.doctest.target %.py.pytest.target build-python test-python cfg-py
