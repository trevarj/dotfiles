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
		esac
		if [ "$i" -gt 0 ]; then
			offset="+${i}month"
		elif [ "$i" -lt 0 ]; then
			offset="${i}month"
		else
			offset=
		fi
	done
}

t=0
toggle() {
	t=$(((t + 1) % 2))
	if [ $t -eq 1 ]; then
		kitty --name cal --hold bash -c "$(declare -f launch_cal); tput civis; launch_cal;" 2>/dev/null &
		kitty_pid=$!
	else
		kill "$kitty_pid" >/dev/null 2>&1
	fi
}

trap "toggle" USR1

echo "󰃭"
while true; do
	sleep 60 &
	wait >/dev/null 2>&1
done
