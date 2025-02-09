#PYTHON_FILES := $(filter-out %_test.py,$(filter-out test_%.py,$(PYTHON_FILES)))
PYTHON_BUILD_TARGETS := $(patsubst %.py,%.py.build.target,$(PYTHON_FILES))
PYTHON_DOCTEST_TARGETS := $(patsubst %.py,%.py.doctest.target,$(PYTHON_FILES))
PYTHON_PYTEST_TARGETS := $(patsubst %.py,%.py.pytest.target,$(PYTHON_TESTS))
MYPY := $(shell which mypy)
DOCTEST := python3 -m doctest
PYTEST := $(shell which pytest)

# Use mypy.ini in the make file directory by default
MYPY_CONFIG_PATH ?= $(wildcard mypy.ini)
MYPY_CONFIG_OPTS :=  --ignore-missing-imports
ifneq ($(strip $(MYPY_CONFIG_PATH)),)
	MYPY_CONFIG_OPTS += --config-file="$(MYPY_CONFIG_PATH)"
endif

build-python: $(PYTHON_BUILD_TARGETS) | silent

test-python: build-python $(PYTHON_DOCTEST_TARGETS) $(PYTHON_PYTEST_TARGETS) | silent

cfg-python: | silent
	@$(MSG) "[CFG]" "Python"
	@$(CFGMSG) "PYTHON_FILES:" "$(PYTHON_FILES)"

%.py.build.target: %.py
	@$(MSG) "[PY]" "$<"
	$(V)$(MYPY) $(MYPY_CONFIG_OPTS) $< --no-color-output $(PROCESS_OUTPUT)

%.py.doctest.target: %.py
	@$(MSG) "[TEST]" "$<"
	$(V)$(DOCTEST) $<

%.py.pytest.target: %.py
	@$(MSG) "[TEST]" "$<"
	$(V)$(PYTEST) $<

.PHONY: %.py.build.target %.py.doctest.target %.py.pytest.target build-python test-python cfg-py
