#!/bin/bash

echo "󰃭"

launch_cal() {
	i=0
	while true; do
		clear
		# shellcheck disable=SC2086
		cal -m -- $offset
		read -rsn1 key
		case "$key" in
		n)
			((i++))
			;;
		p)
			((i--))
			;;
		esac
		if [ "$i" -gt 0 ]; then
			offset="+${i}month"
		elif [ "$i" -lt 0 ]; then
			offset="${i}month"
		fi
	done
}

case "$1" in
--toggle)
	if ! pgrep cal.sh | grep -v "$$" | xargs -n1 pkill -P; then
		kitty --name cal --hold bash -c "$(declare -f launch_cal); tput civis; launch_cal;"
	fi
	;;
esac
