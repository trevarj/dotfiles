#!/bin/sh

cmd="-R"
if [ "$1" = "-d" ]; then
	cmd="-D"
fi

packages=$(fd -t d -d 1 -E _untracked | sed 's/^\.\///; s/\/$//')

for p in $packages; do
	stow "$cmd" "$p"
done
