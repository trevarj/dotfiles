# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=2000
SAVEHIST=6000
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/trevor/.zshrc'
zmodload zsh/complist
zstyle ':completion:*' menu yes select

bindkey -M menuselect '?' history-incremental-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[2~' vi-put-after
bindkey '^[[3~' delete-char

ZSH_AUTOSUGGEST_USE_ASYNC=true
bindkey '^ ' autosuggest-accept

TERM=alacritty
EDITOR=vim

autoload -Uz compinit
compinit
# End of lines added by compinstall

alias ls='exa'

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(starship init zsh)"
