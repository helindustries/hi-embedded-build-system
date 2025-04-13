CPU := $(PLATFORM_ID)
CORE_PLATFORM = $(PLATFORM)

include $(MAKE_INC_PATH)/Architectures/Mac/Toolchain.mk
include $(MAKE_INC_PATH)/Architectures/Mac/Targets.mk
