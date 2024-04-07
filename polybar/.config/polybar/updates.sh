#!/bin/sh
# Check for updates on Arch or Gentoo

if [ -e /etc/gentoo-release ]; then
	is_gentoo=1
fi

case "$1" in
run)
	if [ -n "$is_gentoo" ]; then
		sudo emerge --ask --deep --update @world
	else
		sudo pacman -Syu
	fi
	;;
*)
	if [ -n "$is_gentoo" ]; then
		if [ -f "/tmp/updates.emerge" ]; then
			updates=$(cat "/tmp/updates.emerge")
		else
			updates=$(emerge -DNuvp --quiet world | wc -l)
		fi
	else
		updates=$(checkupdates 2>/dev/null | wc -l)
	fi

	if [ $((updates)) -gt 0 ]; then
		echo "󰏗 $updates"
	else
		echo ""
	fi
	;;
esac
