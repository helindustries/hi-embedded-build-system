CPPFLAGS += $(INCLUDE_PATHS:%=-I%)
LDFLAGS += $(LIBRARY_PATHS:%=-L%) $(LIBS:%=-l%)

upload_macos: binary-cpu

upload_macos_jtag:

clean_macos:
