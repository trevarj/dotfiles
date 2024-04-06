# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]]; then
	# Shell is non-interactive.  Be done now!
	return
else 
  source "$HOME/.local/share/blesh/ble.sh" --rcfile "$HOME/.blerc"
fi


# Put your fun stuff here.

source /etc/bash/bashrc

### Options
set -o history

# Aliases
alias open=xdg-open


### Prompt

# Syntactic sugar for ANSI escape sequences
txtblk='\e[0;30m' # Black - Regular
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
bldblk='\e[1;30m' # Black - Bold
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
unkblk='\e[4;30m' # Black - Underline
undred='\e[4;31m' # Red
undgrn='\e[4;32m' # Green
undylw='\e[4;33m' # Yellow
undblu='\e[4;34m' # Blue
undpur='\e[4;35m' # Purple
undcyn='\e[4;36m' # Cyan
undwht='\e[4;37m' # White
bakblk='\e[40m'   # Black - Background
bakred='\e[41m'   # Red
badgrn='\e[42m'   # Green
bakylw='\e[43m'   # Yellow
bakblu='\e[44m'   # Blue
bakpur='\e[45m'   # Purple
bakcyn='\e[46m'   # Cyan
bakwht='\e[47m'   # White
txtrst='\e[0m'    # Text Reset

# Git 
source "/usr/share/git/git-prompt.sh"
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM=git
GIT_PS1_SHOWCONFLICTSTATE=yes
GIT_PS1_SHOWCOLORHINTS=true

PROMPT_PATH="$bldblu\w$txtrst "

COLOR="\$(if [[ \$? -gt 0 ]]; then printf \$bldred; else printf \$txtgrn; fi)"
ARROW="\n$COLOR➜ $txtrst"
PROMPT_COMMAND='__git_ps1 "$PROMPT_PATH" "$ARROW"'

### FZF 
source "/usr/share/fzf/key-bindings.bash"
source "/usr/share/bash-completion/completions/fzf"
export FZF_DEFAULT_OPTS='--color=bg+:#3B4252,bg:#2E3440,spinner:#81A1C1,hl:#616E88,fg:#D8DEE9,header:#616E88,info:#81A1C1,pointer:#81A1C1,marker:#81A1C1,fg+:#D8DEE9,prompt:#81A1C1,hl+:#81A1C1'

### Environments
# Rust
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Haskell
[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env"

# Go
export GOPATH="$HOME/Workspace"

[[ ${BLE_VERSION-} ]] && ble-attach
