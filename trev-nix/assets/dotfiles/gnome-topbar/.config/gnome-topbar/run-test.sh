#!/usr/bin/env sh
set -eu

cd /home/trev/Workspace/gnome-topbar

exec guix shell -m manifest.scm -- sh -c '
export LD_LIBRARY_PATH=$LIBRARY_PATH
exec ./target/release/gnome-topbar --config /home/trev/Workspace/dotfiles/gnome-topbar/.config/gnome-topbar/config.toml -v
'
