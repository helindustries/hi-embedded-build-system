ifeq ($(strip $(shell uname -s)),Darwin)
    PLATFORM = MacOS
    # XXX: Add app package support once we move to a functional sim
    #PLATFORM_EXEC_OPEN = open
    #PLATFORM_EXEC_EXT = .app
    PLATFORM_EXEC_OPEN =
    PLATFORM_EXEC_EXT =
else
ifeq ($(strip $(shell uname -s)),Linux)
    PLATFORM = Linux
    PLATFORM_EXEC_OPEN =
    PLATFORM_EXEC_EXT =
else
    PLATFORM = Windows
    PLATFORM_EXEC_OPEN =
    PLATFORM_EXEC_EXT = .exe
    ifneq ($(findstring CYGWIN,$(shell uname -o 2>/dev/null)),)
        # Cygwin can be handled like a Unix system, even though it is on Windows, although some tools
        # do require paths to be formatted for Windows. If this is not set, assume we are using MSYS
        WINDOWS_HAS_CYGWIN = yes
    endif
endif
endif

PLATFORM_ID = $(shell echo "$(PLATFORM)" | tr '[:upper:]' '[:lower:]')

# Use this to create paths compatible with the current platforms Make implementation,
# so the same on Unix but /<drive>/<path> on Windows or /cygdrive/<drive>/<path> on Cygwin.
# Only this at the last moment, so either in the target or when calling the actual command!
ifeq ($(strip $(PLATFORM_ID)),windows)
    ifeq ($(strip $(WINDOWS_HAS_CYGWIN)),yes)
        to-make-path = $(shell cygpath -u "$(1)")
    else
        to-make-path = $(shell echo "$(strip $(1))" | sed -E 's%\;([a-zA-Z]+)\:/%;/\L\1/%g' | sed -E 's%(^[a-zA-Z]+)\:/%/\L\1/%' | sed -E 's%\\%/%g' | sed -E 's%//%/%g')
    endif
else
    to-make-path = $(1)
endif
to-make-paths = $(foreach path,$(1),$(call to-make-path,$(path)))

# Use this to make a path compatible with the platforms shell paths, so the same on Unix but
# <drive>:/<path> on Windows or /cygdrive/<drive>/<path> on Cygwin
ifeq ($(strip $(PLATFORM_ID)),windows)
    ifeq ($(strip $(WINDOWS_HAS_CYGWIN)),yes)
        to-shell-path = $(shell cygpath -w "$(1)")
    else
        to-shell-path = $(shell echo "$(strip $(1))" | sed -E 's%\;/([a-zA-Z]+)/%;\1:%' | sed -E 's%\;/cygdrive/([a-zA-Z]+)/%;\1:%' | sed -E 's%^/cygdrive/([a-zA-Z]+)/%\1:%' | sed -E 's%^/([a-zA-Z]+)/%\1:%' | sed -E 's%\\%/%' | sed -E 's%//%/%')
    endif
else
    to-shell-path = $(1)
endif
to-shell-paths = $(foreach path,$(1),$(call to-shell-path,$(path)))

ifeq ($(strip $(PLATFORM_ID)),windows)
    ifeq ($(WINDOWS_HAS_CYGWIN),yes)
        to-shell-list = $(subst ::,:,$(patsubst ::%,%,$(patsubst %::,%,$(subst $(tab),:,$(subst $(space),:,$(strip $(1)))))))
    else
        to-shell-list = $(subst ;,;,$(patsubst ;%,%,$(patsubst %;,%,$(subst $(tab),;,$(subst $(space),;,$(strip $(1)))))))
    endif
else
	to-shell-list = $(subst ::,:,$(patsubst ::%,%,$(patsubst %::,%,$(subst $(tab),:,$(subst $(space),:,$(strip $(1)))))))
endif
