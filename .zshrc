# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=2000
SAVEHIST=6000
unsetopt beep
setopt nonomatch
# bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/trevor/.zshrc'
zmodload zsh/complist
zstyle ':completion:*' menu yes select

bindkey -M menuselect '?' history-incremental-search-forward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^[[2~' vi-put-after
bindkey '^[[3~' delete-char
bindkey "^R" history-incremental-search-backward
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

ZSH_AUTOSUGGEST_USE_ASYNC=true
bindkey '^ ' autosuggest-accept

export TERM=alacritty
export EDITOR=vim

autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit
# End of lines added by compinstall

alias ls='exa'
alias open='xdg-open'
alias idris2='rlwrap idris2'

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(pack completion-script pack)"
eval "$(oh-my-posh init --config ~/.config/oh-my-posh/theme.omp.json zsh)"

# opam configuration
[[ ! -r /home/trevor/.opam/opam-init/init.zsh ]] || source /home/trevor/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null
