CPPFLAGS += $(INCLUDE_PATHS:%=-I%)
LIBS := $(LIBS:%=-l%)
LDFLAGS += $(LIBRARY_PATHS:%=-L%)

upload_macos: binary-cpu

upload_macos_jtag:

clean_macos:
