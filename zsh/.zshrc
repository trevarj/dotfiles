[[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

# History
HISTSIZE=10000
HISTFILE="$HOME/.zsh_history"
HIST_STAMPS="mm/dd/yyyy"
HISTORY_IGNORE="(ls|cd|pwd|exit|cd|cp|mv|rm|sudo poweroff|sudo reboot)"
SAVEHIST=$HISTSIZE

# Option
setopt inc_append_history share_history # share history across all instances
setopt hist_ignore_all_dups # ignore history duplicates
setopt hist_ignore_space # ignore recording commands with a space before
setopt autocd # removes need to write 'cd'

# Keybindings
bindkey -e # emacs
bindkey '^ ' autosuggest-accept

# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

# [PageUp] - Up a line of history
if [[ -n "${terminfo[kpp]}" ]]; then
  bindkey -M emacs "${terminfo[kpp]}" up-line-or-history
fi
# [PageDown] - Down a line of history
if [[ -n "${terminfo[knp]}" ]]; then
  bindkey -M emacs "${terminfo[knp]}" down-line-or-history
fi
# Start typing + [Up-Arrow] - fuzzy find history forward
if [[ -n "${terminfo[kcuu1]}" ]]; then
  autoload -U up-line-or-beginning-search
  zle -N up-line-or-beginning-search
  bindkey -M emacs "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
# Start typing + [Down-Arrow] - fuzzy find history backward
if [[ -n "${terminfo[kcud1]}" ]]; then
  autoload -U down-line-or-beginning-search
  zle -N down-line-or-beginning-search
  bindkey -M emacs "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# [Home] - Go to beginning of line
if [[ -n "${terminfo[khome]}" ]]; then
  bindkey -M emacs "${terminfo[khome]}" beginning-of-line
fi
# [End] - Go to end of line
if [[ -n "${terminfo[kend]}" ]]; then
  bindkey -M emacs "${terminfo[kend]}"  end-of-line
fi

# [Shift-Tab] - move through the completion menu backwards
if [[ -n "${terminfo[kcbt]}" ]]; then
  bindkey -M emacs "${terminfo[kcbt]}" reverse-menu-complete
fi

# [Backspace] - delete backward
bindkey -M emacs '^?' backward-delete-char
# [Delete] - delete forward
if [[ -n "${terminfo[kdch1]}" ]]; then
  bindkey -M emacs "${terminfo[kdch1]}" delete-char
else
  bindkey -M emacs "^[[3~" delete-char
  bindkey -M emacs "^[3;5~" delete-char
fi

# [Ctrl-Delete] - delete whole forward-word
bindkey -M emacs '^[[3;5~' kill-word
# [Ctrl-RightArrow] - move forward one word
bindkey -M emacs '^[[1;5C' forward-word
# [Ctrl-LeftArrow] - move backward one word
bindkey -M emacs '^[[1;5D' backward-word

bindkey '\ew' kill-region                             # [Esc-w] - Kill from the cursor to the mark
bindkey -s '\el' 'ls\n'                               # [Esc-l] - run command: ls
bindkey '^r' history-incremental-search-backward      # [Ctrl-r] - Search backward incrementally for a specified string. The string may begin with ^ to anchor the search to the beginning of the line.
bindkey ' ' magic-space                               # [Space] - don't do history expansion

## Aliases

alias sudo='sudo '
alias open='xdg-open'
alias tb='nc termbin.com 9999'
alias et='emacs -nw'

## eza instead of ls
source ~/.zsh_eza.zsh

# Autosuggetions (ghost text)
source /usr/share{,/zsh/plugins}/zsh-autosuggestions/zsh-autosuggestions.zsh(N)

# Syntax highlighting on command line
source /usr/share{,/zsh/plugins}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh(N)

# Prompt
source $HOME/.zsh_prompt.zsh-theme

# Load and initialise completion system
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
autoload -Uz compinit
compinit

# Edit current line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# Ffz-tab completion
# must come after compinit
rc_path=$(realpath ~/.zshrc)
zstyle ':fzf-tab:*' use-fzf-default-opts yes
source "$(dirname $rc_path)/../fzf-tab/fzf-tab.plugin.zsh"

eval "$(direnv hook zsh)"
