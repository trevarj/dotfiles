#!/bin/bash

cmd="-R"
if [ "$1" = "-d" ]; then
  cmd="-D"
fi

packages=$(fd -t d -d 1 -E _untracked | sed 's/^\.\///; s/\/$//')

for p in $packages; do
  if [ "$p" = "firefox" ]; then
    # firefox profiles are not consistantly named, only a guess
    profile=$(fd --type=d --glob "*default-release*" ~/.mozilla)
    mkdir "$profile"chrome >/dev/null 2>&1
    stow -t "$profile"/chrome "$cmd" "$p"
  else
    stow "$cmd" "$p"
  fi
done
