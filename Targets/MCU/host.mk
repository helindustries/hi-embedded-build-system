MCU := host
CPU_CPPFLAGS :=
CPU_LDFLAGS :=
CORE_PLATFORM := Host

include $(MAKE_INC_PATH)/Platforms/Host/Toolchain.mk
include $(MAKE_INC_PATH)/Platforms/Host/Targets.mk
