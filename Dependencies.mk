DEPENDENCY_LIB_NAMES := $(foreach dep,$(filter Lib:%,$(DEPENDENCIES)),$(word 2,$(subst :, ,$(dep))))
DEPENDENCY_LIBS := $(DEPENDENCY_LIB_NAMES:%=lib%-$(MCU).a)
DEPENDENCY_LIB_TARGETS := $(DEPENDENCY_LIBS:%=%.dependency)
DEPENDENCY_LIB_PATHS := $(foreach dep,$(DEPENDENCY_LIB_NAMES),$(BUILD_DIR)/$(dep)/lib$(dep)-$(MCU).a)

DEPENDENCY_EXEC_NAMES := $(foreach dep,$(filter Exec:%,$(DEPENDENCIES)),$(word 2,$(subst :, ,$(dep))))
DEPENDENCY_EXEC_TARGETS := $(DEPENDENCY_EXEC_NAMES:%=%-$(MCU).exec.dependency)

ifneq ($(strip $(NO_GATEWARE_DEPS)),yes)
DEPENDENCY_GATEWARE_NAMES := $(foreach dep,$(filter Gateware:%,$(DEPENDENCIES)),$(word 2,$(subst :, ,$(dep))))
DEPENDENCY_GATEWARE_TARGETS := $(DEPENDENCY_GATEWARE_NAMES:%=%-$(FPGA_BOARD).gateware.dependency)
endif

ifneq ($(strip $(NO_TOOLS_DEPS)),yes)
DEPENDENCY_TOOL_NAMES := $(foreach dep,$(filter Tool:%,$(DEPENDENCIES)),$(word 2,$(subst :, ,$(dep))))
DEPENDENCY_TOOL_TARGETS := $(DEPENDENCY_TOOL_NAMES:%=%.tool.dependency)
endif

ifneq ($(strip $(NO_TESTS_DEPS)),yes)
DEPENDENCY_TEST_NAMES := $(foreach dep,$(filter Test:%,$(DEPENDENCIES)),$(word 2,$(subst :, ,$(dep))))
DEPENDENCY_TEST_TARGETS := $(DEPENDENCY_TEST_NAMES:%=%.test.dependency)
endif

DEPENDENCY_MAKE_NAMES := $(foreach dep,$(filter Make:%,$(DEPENDENCIES)),$(word 2,$(subst :, ,$(dep))))
DEPENDENCY_MAKE_TARGETS := $(DEPENDENCY_MAKE_NAMES:%=%.make.dependency)
DEPENDENCY_TARGETS := $(DEPENDENCY_TOOL_TARGETS) $(DEPENDENCY_LIB_TARGETS) $(DEPENDENCY_EXEC_TARGETS) $(DEPENDENCY_GATEWARE_TARGETS) $(DEPENDENCY_MAKE_TARGETS) $(DEPENDENCY_TEST_TARGETS)
$(foreach mod,$(DEPENDENCIES),$(eval DEPENDENCY_PATH_$(word 2,$(subst :, ,$(mod))) = $(abspath $(lastword $(subst :, ,$(mod))))))

# Libs need to be placed in the build dir after building. This is different than a module, it requires a makefile to be present,
# so it is not viable to be used with Arduino libs.
lib%-$(MCU).a.dependency:
ifeq ($(strip $(VERBOSE)),1)
	@$(VMSG) "Building lib$*-$(MCU).a.dependency"
	@$(VCFGMSG) "NAME:" "$*"
	@$(VCFGMSG) "PATH:" "$(DEPENDENCY_PATH_$*)"
	@$(VCFGMSG) "BUILD_DIR:" "$(BUILD_DIR)/$*"
	@$(VCFGMSG) "MCU_BOARD:" "$(MCU_BOARD)"
	@$(VCFGMSG) "FPGA_BOARD:" "$(FPGA_BOARD)"
	@$(VCFGMSG) "MCU_EXEC_OFFSET:" "$(MCU_EXEC_OFFSET)"
	@$(VCFGMSG) "OPTIMIZE:" "$(OPTIMIZE)"
	@$(VCFGMSG) "VERBOSE:" "$(VERBOSE)"
	@$(VCFGMSG) "DEBUG:" "$(DEBUG)"
	@$(VCFGMSG) "MCU:" "$(MCU)"
	@$(VCFGMSG) "CPU_SPEED:" "$(CPU_SPEED)"
	@$(VCFGMSG) "BUS_SPEED:" "$(BUS_SPEED)"
	@$(VCFGMSG) "CPUARCH:" "$(CPUARCH)"
	@$(VCFGMSG) "CPU_CPPFLAGS:" "$(CPU_CPPFLAGS)"
	@$(VCFGMSG) "CPU_LDFLAGS:" "$(CPU_LDFLAGS)"
	@$(VCFGMSG) "SERIAL_ID:" "$(SERIAL_ID)"
	@$(VCFGMSG) "MCU_BOARD_OPTS:" "$(MCU_BOARD_OPTS)"
	@$(VCFGMSG) "CORE_LIB_PATH:" "$(CORE_LIB_PATH)"
	@$(VCFGMSG) "CORE_PATH:" "$(CORE_PATH)"
else
	@$(MSG) "[LIB]" "$*"
endif
	$(V)$(MAKE) --directory="$(DEPENDENCY_PATH_$*)" --file "$(DEPENDENCY_PATH_$*)/Makefile" "MAKE_INC_PATH=$(MAKE_INC_PATH)" "MCU_TARGET=$*" "BUILD_DIR=$(BUILD_DIR)/$*" "MCU_BOARD=$(MCU_BOARD)" "MCU_EXEC_OFFSET=$(MCU_EXEC_OFFSET)" "OPTIMIZE=$(OPTIMIZE)" "VERBOSE=$(VERBOSE)" "DEBUG=$(DEBUG)" "MCU=$(MCU)" "CPU_SPEED=$(CPU_SPEED)" "BUS_SPEED=$(BUS_SPEED)" "CPUARCH=$(CPUARCH)" "CPU_CPPFLAGS=$(CPU_CPPFLAGS)" "CPU_LDFLAGS=$(CPU_LDFLAGS)" "SERIAL_ID=$(SERIAL_ID)" "MCU_BOARD_OPTS=$(MCU_BOARD_OPTS)" "CORE_LIB_PATH=$(CORE_LIB_PATH)" "CORE_PATH=$(CORE_PATH)" "NO_GATEWARE_DEPS=$(NO_GATEWARE_DEPS)" "NO_TOOLS_DEPS=$(NO_TOOLS_DEPS)" "NO_TESTS_DEPS=$(NO_TESTS_DEPS)" "NO_GATEWARE_UPLOAD=$(NO_GATEWARE_UPLOAD)" $(MAKECMDGOALS)

# Executables need to be built and then installed before deploying to MCU, they need to adhere to prefix, so they can be included
# in an image. The idea is to load them onto an SD card and load them into memory at runtime
%-$(MCU).exec.dependency:
ifeq ($(strip $(VERBOSE)),1)
	@$(VMSG) "Building $*-$(MCU).exec.dependency"
	@$(VCFGMSG) "NAME:" "$*"
	@$(VCFGMSG) "PATH:" "$(DEPENDENCY_PATH_$*)"
	@$(VCFGMSG) "BUILD_DIR:" "$(BUILD_DIR)/$*"
	@$(VCFGMSG) "MCU_BOARD:" "$(MCU_BOARD)"
	@$(VCFGMSG) "FPGA_BOARD:" "$(FPGA_BOARD)"
	@$(VCFGMSG) "MCU_EXEC_OFFSET:" "$(MCU_EXEC_OFFSET)"
	@$(VCFGMSG) "VERBOSE:" "$(VERBOSE)"
	@$(VCFGMSG) "DEBUG:" "$(DEBUG)"
	@$(VCFGMSG) "MCU:" "$(MCU)"
	@$(VCFGMSG) "CPU_SPEED:" "$(CPU_SPEED)"
	@$(VCFGMSG) "BUS_SPEED:" "$(BUS_SPEED)"
	@$(VCFGMSG) "CPUARCH:" "$(CPUARCH)"
	@$(VCFGMSG) "CPU_CPPFLAGS:" "$(CPU_CPPFLAGS)"
	@$(VCFGMSG) "CPU_LDFLAGS:" "$(CPU_LDFLAGS)"
	@$(VCFGMSG) "SERIAL_ID:" "$(SERIAL_ID)"
	@$(VCFGMSG) "MCU_BOARD_OPTS:" "$(MCU_BOARD_OPTS)"
	@$(VCFGMSG) "CORE_LIB_PATH:" "$(CORE_LIB_PATH)"
	@$(VCFGMSG) "CORE_PATH:" "$(CORE_PATH)"
else
	@$(MSG) "[EXEC]" "t$*"
endif
	$(V)$(MAKE) --directory="$(DEPENDENCY_PATH_$*)" --file "$(DEPENDENCY_PATH_$*)/Makefile" "MAKE_INC_PATH=$(MAKE_INC_PATH)" "MCU_TARGET=$*" "BUILD_DIR=$(BUILD_DIR)/$*" "MCU_BOARD=$(MCU_BOARD)" "MCU_EXEC_OFFSET=$(MCU_EXEC_OFFSET)" "OPTIMIZE=$(OPTIMIZE)" "VERBOSE=$(VERBOSE)" "DEBUG=$(DEBUG)" "MCU=$(MCU)" "CPU_SPEED=$(CPU_SPEED)" "BUS_SPEED=$(BUS_SPEED)" "CPUARCH=$(CPUARCH)" "CPU_CPPFLAGS=$(CPU_CPPFLAGS)" "CPU_LDFLAGS=$(CPU_LDFLAGS)" "SERIAL_ID=$(SERIAL_ID)" "MCU_BOARD_OPTS=$(MCU_BOARD_OPTS)" "CORE_LIB_PATH=$(CORE_LIB_PATH)" "CORE_PATH=$(CORE_PATH)" "NO_GATEWARE_DEPS=$(NO_GATEWARE_DEPS)" "NO_TOOLS_DEPS=$(NO_TOOLS_DEPS)" "NO_TESTS_DEPS=$(NO_TESTS_DEPS)" "NO_GATEWARE_UPLOAD=$(NO_GATEWARE_UPLOAD)" $(MAKECMDGOALS)

# Gateware needs to be uploaded when deploying, but only directly from its directory if to flash or during MCU install if JTAG
%-$(FPGA_BOARD).gateware.dependency:
ifeq ($(strip $(VERBOSE)),1)
	@$(VMSG) "Building $*-$(FPGA_BOARD).gateware.dependency"
	@$(VCFGMSG) "NAME:" "$*"
	@$(VCFGMSG) "PATH:" "$(DEPENDENCY_PATH_$*)"
	@$(VCFGMSG) "PATH:" "$(DEPENDENCY_PATH_$*)"
	@$(VCFGMSG) "BUILD_DIR:" "$(BUILD_DIR)/$*"
	@$(VCFGMSG) "FPGA_BOARD:" "$(FPGA_BOARD)"
	@$(VCFGMSG) "VERBOSE:" "$(VERBOSE)"
	@$(VCFGMSG) "DEBUG:" "$(DEBUG)"
	@$(VCFGMSG) "NO_GATEWARE_UPLOAD:" "$(NO_GATEWARE_UPLOAD)"
else
	@$(MSG) "[GATE]" "$*"
endif
	$(V)$(MAKE) --directory="$(DEPENDENCY_PATH_$*)" --file "$(DEPENDENCY_PATH_$*)/Makefile" "MAKE_INC_PATH=$(MAKE_INC_PATH)" "MCU_TARGET=$*" "BUILD_DIR=$(BUILD_DIR)/$*" "FPGA_BOARD=$(FPGA_BOARD)" "VERBOSE=$(VERBOSE)" "DEBUG=$(DEBUG)" "NO_GATEWARE_UPLOAD=$(NO_GATEWARE_UPLOAD)" "NO_GATEWARE_DEPS=$(NO_GATEWARE_DEPS)" "NO_TOOLS_DEPS=$(NO_TOOLS_DEPS)" "NO_TESTS_DEPS=$(NO_TESTS_DEPS)" "NO_GATEWARE_UPLOAD=$(NO_GATEWARE_UPLOAD)" $(MAKECMDGOALS)

# Tools need to be built, but for the current platform, not for the target platform, they don't need to run install
%.tool.dependency:
ifeq ($(strip $(VERBOSE)),1)
	@$(VMSG) "Building $*.tool.dependency"
	@$(VCFGMSG) "NAME:" "$*"
	@$(VCFGMSG) "PATH:" "$(DEPENDENCY_PATH_$*)"
	@$(VCFGMSG) "BUILD_DIR:" "$(BUILD_DIR)/$*"
	@$(VCFGMSG) "MCU_BOARD:" "$(MCU_BOARD)"
	@$(VCFGMSG) "FPGA_BOARD:" "$(FPGA_BOARD)"
	@$(VCFGMSG) "OPTIMIZE:" "$(OPTIMIZE)"
	@$(VCFGMSG) "VERBOSE:" "$(VERBOSE)"
	@$(VCFGMSG) "DEBUG:" "$(DEBUG)"
else
	@$(MSG) "[TOOL]" "$*"
endif
	$(V)$(MAKE) --directory="$(DEPENDENCY_PATH_$*)" --file "$(DEPENDENCY_PATH_$*)/Makefile" "MAKE_INC_PATH=$(MAKE_INC_PATH)" "MCU_TARGET=$*" "BUILD_DIR=$(BUILD_DIR)/$*" "OPTIMIZE=$(OPTIMIZE)" "VERBOSE=$(VERBOSE)" "DEBUG=$(DEBUG)" "NO_GATEWARE_DEPS=$(NO_GATEWARE_DEPS)" "NO_TOOLS_DEPS=$(NO_TOOLS_DEPS)" "NO_TESTS_DEPS=$(NO_TESTS_DEPS)" "NO_GATEWARE_UPLOAD=$(NO_GATEWARE_UPLOAD)" $(MAKECMDGOALS)

# Tests need to be built, but for the current platform, not for the target platform, they then need to be run upon make directly
%.test.dependency:
ifeq ($(strip $(VERBOSE)),1)
	@$(VMSG) "Building $*.test.dependency"
	@$(VCFGMSG) "NAME:" "$*"
	@$(VCFGMSG) "PATH:" "$(DEPENDENCY_PATH_$*)"
	@$(VCFGMSG) "BUILD_DIR:" "$(BUILD_DIR)/$*"
	@$(VCFGMSG) "MCU_BOARD:" "$(MCU_BOARD)"
	@$(VCFGMSG) "FPGA_BOARD:" "$(FPGA_BOARD)"
	@$(VCFGMSG) "OPTIMIZE:" "$(OPTIMIZE)"
	@$(VCFGMSG) "VERBOSE:" "$(VERBOSE)"
	@$(VCFGMSG) "DEBUG:" "$(DEBUG)"
else
	@$(MSG) "[TEST]" "$*"
endif
	$(V)$(MAKE) --directory="$(DEPENDENCY_PATH_$*)" --file "$(DEPENDENCY_PATH_$*)/Makefile" "MAKE_INC_PATH=$(MAKE_INC_PATH)" "MCU_TARGET=$*" "BUILD_DIR=$(BUILD_DIR)/$*" "OPTIMIZE=$(OPTIMIZE)" "VERBOSE=$(VERBOSE)" "DEBUG=$(DEBUG)" "NO_GATEWARE_DEPS=$(NO_GATEWARE_DEPS)" "NO_TOOLS_DEPS=$(NO_TOOLS_DEPS)" "NO_TESTS_DEPS=$(NO_TESTS_DEPS)" "NO_GATEWARE_UPLOAD=$(NO_GATEWARE_UPLOAD)" $(MAKECMDGOALS)

# Make targets need to just call make in the directory, not caring about anything else, but still passing base config like build dir
%.make.dependency:
ifeq ($(strip $(VERBOSE)),1)
	@$(VMSG) "Building $*.make.dependency"
	@$(VCFGMSG) "NAME:" "$*"
	@$(VCFGMSG) "PATH:" "$(DEPENDENCY_PATH_$*)"
	@$(VCFGMSG) "BUILD_DIR:" "$(BUILD_DIR)/$*"
	@$(VCFGMSG) "MCU_BOARD:" "$(MCU_BOARD)"
	@$(VCFGMSG) "FPGA_BOARD:" "$(FPGA_BOARD)"
	@$(VCFGMSG) "VERBOSE:" "$(VERBOSE)"
	@$(VCFGMSG) "DEBUG:" "$(DEBUG)"
else
	@$(MSG) "[MAKE]" "$*"
endif
	$(V)$(MAKE) --directory="$(DEPENDENCY_PATH_$*)" --file "$(DEPENDENCY_PATH_$*)/Makefile"	"MAKE_INC_PATH=$(MAKE_INC_PATH)" "MCU_TARGET=$*" "BUILD_DIR=$(BUILD_DIR)/$*" "VERBOSE=$(VERBOSE)" "DEBUG=$(DEBUG)" "NO_GATEWARE_DEPS=$(NO_GATEWARE_DEPS)" "NO_TOOLS_DEPS=$(NO_TOOLS_DEPS)" "NO_TESTS_DEPS=$(NO_TESTS_DEPS)" "NO_GATEWARE_UPLOAD=$(NO_GATEWARE_UPLOAD)" $(MAKECMDGOALS)

dependencies: $(DEPENDENCY_TARGETS)

clean-dependencies:
	$(V)rm -f $(DEPENDENCY_LIB_PATHS)

.PHONY: dependencies clean-dependencies