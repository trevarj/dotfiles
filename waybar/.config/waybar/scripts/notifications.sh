#!/usr/bin/env sh
set -euo pipefail

_status() {
    dbus-monitor path='/org/freedesktop/Notifications',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged' --profile |
        while read -r _; do
            paused="$(dunstctl is-paused)"
            count="$(dunstctl count waiting)"
            tooltip=""
            icon=""
            if [ "$paused" == 'true' ]; then
                icon="󰪑"
            elif [ "$1" == 'full' ]; then
                icon="󰂜"
            fi
            if [ "$count" != '0' ]; then
                icon="󰅸"
                tooltip="$count notification(s) awaiting"
            fi
            echo "{\"text\": \"$icon\", \"tooltip\": \"$tooltip\"}"
        done
}

_toggle() {
    dunstctl set-paused toggle
}

case "$1" in
    status) _status "${2:-none}" ;;
    toggle) _toggle ;;
esac
