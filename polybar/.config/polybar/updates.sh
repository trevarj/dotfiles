#!/bin/sh
# Check for updates on Arch or Gentoo

if [ -e /etc/gentoo-release ]; then
	is_gentoo=1
	emerge_update="/tmp/updates.emerge"
fi

case "$1" in
run)
	if [ -n "$is_gentoo" ]; then
		if sudo emerge --ask --deep --update @world; then
			sudo rm "$emerge_update"
			sudo emerge --ask --depclean
		fi
	else
		sudo pacman -Syu
	fi
	;;
*)
	if [ -n "$is_gentoo" ]; then
		# expects a file with the result of `emerge -DNuvp --quiet world | wc -l`
		if [ -f "$emerge_update" ]; then
			updates=$(cat "$emerge_update")
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
