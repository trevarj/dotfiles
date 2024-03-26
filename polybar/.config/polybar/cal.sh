#!/bin/sh

echo "󰃭"
case "$1" in
--toggle)
	if ! pgrep cal.sh | grep -v "$$" | xargs -n1 pkill -P; then
		kitty --name cal --hold sh -c "tput smcup; tput civis; cal; read -r -s password;"
	fi
	;;
*) ;;
esac
