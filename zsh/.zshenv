export PATH=$PATH:"$HOME/.idris2/bin/":"$HOME/.pack/bin:"$HOME"/.local/bin":"$HOME/.luarocks/bin/"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$HOME/.idris2/lib/"
export GOPATH="$HOME/Workspace"
export FZF_DEFAULT_OPTS='--color=bg+:#3B4252,bg:#2E3440,spinner:#81A1C1,hl:#616E88,fg:#D8DEE9,header:#616E88,info:#81A1C1,pointer:#81A1C1,marker:#81A1C1,fg+:#D8DEE9,prompt:#81A1C1,hl+:#81A1C1'
export GUILE_LOAD_COMPILED_PATH="/usr/local/lib/guile/3.0/site-ccache${GUILE_LOAD_COMPILED_PATH:+:}$GUILE_COMPILED_LOAD_PATH"
export GUILE_LOAD_PATH="/usr/local/share/guile/site/3.0${GUILE_LOAD_PATH:+:}$GUILE_LOAD_PATH"
. "$HOME/.cargo/env"
eval $(opam env)

