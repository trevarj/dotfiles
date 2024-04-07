# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "embeddedpenguin/sanekeybinds"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/exa"
plug "zsh-users/zsh-syntax-highlighting"
plug "hlissner/zsh-autopair"
plug "Aloxaf/fzf-tab"
plug "trevarj/zsh-prompt"
# plug "$HOME/Workspace/zsh-prompt"

# Custom configs
bindkey '^ ' autosuggest-accept

HIST_STAMPS="mm/dd/yyyy"

export EDITOR='nvim'
export LANGUAGE='en_US.UTF-8'
export LANG='en_US.UTF-8'
export LC_TYPE='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export LESSCOLORIZER='bat --color=always --style=plain,changes' # for lesspipe
export BAT_THEME='Nord'
GPG_TTY=$(tty)
export GPG_TTY

alias open='xdg-open'

# Load and initialise completion system
autoload -Uz compinit
compinit
