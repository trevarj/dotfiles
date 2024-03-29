#!/bin/bash

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
		q)
			break
			;;
		esac
		if [ "$i" -gt 0 ]; then
			offset="+${i}month"
		elif [ "$i" -lt 0 ]; then
			offset="${i}month"
		else
			unset offset
		fi
	done
}

toggle() {
	ps -p "$kitty_pid" >/dev/null 2>&1
	alive=$? # may have been killed with 'q'
	if [[ -n "$kitty_pid" && $alive == 0 ]]; then
		kill "$kitty_pid"
		unset kitty_pid
	else
		kitty --name cal bash -c "$(declare -f launch_cal); tput civis; launch_cal;" 2>/dev/null &
		kitty_pid=$!
	fi
}

trap "toggle" USR1

echo "󰃭"
while true; do
	sleep 60 &
	wait
done
