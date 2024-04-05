if [[ -z $TMUX ]]; then
  path+=("$HOME/.local/bin" "$HOME/.luarocks/bin/")
  export PATH
fi
export FZF_DEFAULT_OPTS='--color=bg+:#3B4252,bg:#2E3440,spinner:#81A1C1,hl:#616E88,fg:#D8DEE9,header:#616E88,info:#81A1C1,pointer:#81A1C1,marker:#81A1C1,fg+:#D8DEE9,prompt:#81A1C1,hl+:#81A1C1'

# Go
export GOPATH="$HOME/Workspace"

# Haskell
[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env"

# Rust
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Ocaml
# eval $(opam env)

# Must be last
if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
          exec startx
fi
