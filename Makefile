first: all

BUILD_DIR ?= Build
include BuildSystem.mk

TOPTARGETS := all install simulate test clean cfg
SUBDIRS := $(foreach subdir,$(wildcard */Makefile),$(dir $(subdir)))

include $(MAKE_INC_PATH)/SubTargets.mk
