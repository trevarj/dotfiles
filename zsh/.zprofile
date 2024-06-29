# Merge search-paths from multiple profiles, the order matters.
eval "$(guix package --search-paths \
-p $HOME/.config/guix/current \
-p $HOME/.guix-home/profile \
-p $HOME/.guix-profile \
-p /run/current-system/profile)"

# Prepend setuid programs.
export PATH=/run/setuid-programs:$PATH

export EDITOR='emacs -nw'
export VISUAL='emacs'
export LANGUAGE='en_US.UTF-8'
export LANG='en_US.UTF-8'
export LC_TYPE='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export LESSCOLORIZER='bat --color=always --style=plain,changes' # for lesspipe
export BAT_THEME='Nord'
GPG_TTY=$(tty)
export GPG_TTY

# Flatpak apps in launcher
export XDG_DATA_DIRS="$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share"

export FZF_DEFAULT_OPTS='--color=bg+:#3B4252,bg:#2E3440,spinner:#81A1C1,hl:#616E88,fg:#D8DEE9,header:#616E88,info:#81A1C1,pointer:#81A1C1,marker:#81A1C1,fg+:#D8DEE9,prompt:#81A1C1,hl+:#81A1C1'

# Go
export GOPATH="$HOME/Workspace"

# Haskell
[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env"

# Rust
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Ocaml
# eval $(opam env)

# Start up tmux session
if [ -x "$(command -v tmux)" ] && [ -n "${DISPLAY}" ] && [ -z "${TMUX}" ]; then
  exec tmux a -d >/dev/null 2>&1
fi

echo "HELLO TREV!"

if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec sway
fi
