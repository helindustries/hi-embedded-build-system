#!/bin/bash

function check_recover_drive()
{
    [ "$(check_function get_recover_drive)" != "function" ] && return

    local MCU_RECOVER_DRIVE="$(get_recover_drive)"
    [ -d "$MCU_RECOVER_DRIVE" ] && echo "yes"
}

function install_uf2()
{
    [ "$(check_function get_recover_drive)" != "function" ] && return
    [ "$(check_function get_port)" != "function" ] && return
    local RESET_IMAGE_PATH="$1"
    local MCU_DRIVE_PATH="$(get_recover_drive)"
    shift 1

    [ ! -d "$MCU_DRIVE_PATH" ] && return
    [ ! -f "$RESET_IMAGE_PATH" ] && echo "Please copy the original .uf2 image to $RESET_IMAGE_PATH" && exit 1

    echo "Copying reset image to '$MCU_DRIVE_PATH'"
    cp -f "$RESET_IMAGE_PATH" "$MCU_DRIVE_PATH"
    TIMEOUT=60
    echo "Getting port with '$*'"
    while [ -z "$PORT" ] && [ "$TIMEOUT" != "0" ]; do
        PORT="$(get_port "$@")"
        TIMEOUT=$((TIMEOUT - 1))
        #echo -n "."
        echo "$TIMEOUT $(get_port $@)"
        sleep 1
    done

    if [ -z "$PORT" ]; then
        echo "Failed to find serial port after reset"
        exit 1
    else
        echo "Device back up at $PORT"
    fi
}

function install()
{
    local MCU_BOARD_PATH="$1"
    shift 1
    install_uf2 "$MCU_BOARD_PATH/reset.uf2" "$@"
    [ "$(check_function send_firmware)" != "function" ] && return
    send_firmware "$MCU_BOARD_PATH" "$@"
}

function check_function()
{
    local NAME=$1
    type "$NAME" 2>&1 | head -n 1 | grep "is a function" > /dev/null && echo "function"
}

echo "Recovery Tool"
BASE_PATH="$(dirname "$0")"
COMMAND="$1"
MCU_BOARD="$2"
MCU_BOARD_PATH="$BASE_PATH/$MCU_BOARD"
[ ! -d "$MCU_BOARD_PATH" ] && echo "No recovery available for $MCU_BOARD" && exit 0
source "$MCU_BOARD_PATH/recover.shinc"
if [ "$(check_function alias_mcu_board)" == "function" ]; then
    MCU_BOARD=$(alias_mcu_board)
    MCU_BOARD_PATH="$BASE_PATH/$MCU_BOARD"
    [ ! -d "$MCU_BOARD_PATH" ] && echo "No recovery available for alias $MCU_BOARD" && exit 0
    [ ! -d "$MCU_BOARD_PATH" ] && echo "Alias board does not exist" && exit 1
    source "$MCU_BOARD_PATH/recover.shinc"
fi
MCU_BASE=$(get_mcu_base)
MCU_BASE_INCLUDE="$BASE_PATH/base/$MCU_BASE.shinc"
[ -f "$MCU_BASE_INCLUDE" ] && echo "Using $MCU_BASE as base" && source "$MCU_BASE_INCLUDE"
shift 2

# command board
# $@ being:
#   esp32: esptool
#   nrf52: pid, vid, nrfutil, [port]

case $COMMAND in
    help)
        echo "usage: $0 <command> <board> <board_args> [port]"
        echo "esp32 args: <esptool>"
        echo "nrf52 args: <pid> <vid> <nrfutil>"
      ;;
    detect)
        [ "$(check_function check_recover)" != "function" ] && echo "No check_recover function" && exit 0
        [ -z "$(check_recover)" ] && echo "No recovery required." && exit 0
        install "$MCU_BOARD_PATH" "$@"
      ;;
    recover)
        install "$MCU_BOARD_PATH" "$@"
      ;;
esac
