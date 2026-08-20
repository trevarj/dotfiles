#!/usr/bin/env bash
# emacs C-x b analog for tmux: pick any pane (across all sessions) and
# replace the current pane with it in-place — no split. swap moves the picked
# pane into the current spot, kill removes the old current pane, select
# restores focus. Empty (fzf cancelled) or self-pick is a no-op.
cur=$(tmux display -p '#{pane_id}')
sel=$(tmux list-panes -a -F '#{pane_id} #{session_name}:#{window_index}.#{pane_index} #{pane_current_command} #{pane_title}' |
  grep -v "^$cur " |
  fzf --prompt='Pane: ' --layout=reverse --info=inline-right --header='replace current pane' |
  awk '{print $1}')
[ -n "${sel:-}" ] && [ "$sel" != "$cur" ] || exit 0
tmux swap-pane -s "$sel" -t "$cur"
tmux kill-pane -t "$cur"
tmux select-pane -t "$sel"
