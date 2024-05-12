#!/bin/bash

cmd="-R"
if [ "$1" = "-d" ]; then
	cmd="-D"
fi

packages=$(fd -t d -d 1 -E _untracked | sed 's/^\.\///; s/\/$//')

for p in $packages; do
	if [ "$p" = "firefox" ]; then
		# firefox profiles are not consistantly named, only a guess
		profile="$HOME/.mozilla/firefox/*default-release*"
	        mkdir $profile/chrome
		# shellcheck disable=SC2086 # intentionally glob the path
		stow -t $profile/chrome "$cmd" "$p"
	else
		stow "$cmd" "$p"
	fi
done
