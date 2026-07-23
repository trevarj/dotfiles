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

export FZF_DEFAULT_OPTS='--color=bg+:#3B4252,bg:#2E3440,spinner:#81A1C1,hl:#616E88,fg:#D8DEE9,header:#616E88,info:#81A1C1,pointer:#81A1C1,marker:#81A1C1,fg+:#D8DEE9,prompt:#81A1C1,hl+:#81A1C1'

export PATH="$HOME/.local/bin:$PATH"

# Go
export GOPATH="$HOME/Workspace"

# Haskell
[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env"

# Rust
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Ocaml
# eval $(opam env)

# Guix
# if command -v "guix" >/dev/null; then
#   GUIX_PROFILE="$HOME/.config/guix/current"
#   . "$GUIX_PROFILE/etc/profile"

#   # Foreign distro only, with nss-certs installed
#   if [[ -d "$HOME/.guix-profile/etc/ssl" ]]; then
#       export SSL_CERT_DIR="$HOME/.guix-profile/etc/ssl/certs"
#       export SSL_CERT_FILE="$HOME/.guix-profile/etc/ssl/certs/ca-certificates.crt"
#       export GIT_SSL_CAINFO="$SSL_CERT_FILE"
#   fi
# fi

niri-session() {
    export XDG_CURRENT_DESKTOP="niri"
    export XDG_SESSION_TYPE="wayland"
    export XDG_SESSION_DESKTOP="niri"
    export GDK_BACKEND="wayland"
    export QT_QPA_PLATFORM="wayland"
    export SDL_VIDEODRIVER="wayland"
    export CLUTTER_BACKEND="wayland"
    export MOZ_ENABLE_WAYLAND=1

    exec niri --session 2>>~/.local/state/niri.log
}
