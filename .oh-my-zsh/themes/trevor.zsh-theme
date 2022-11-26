PROMPT='%{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'
PROMPT+="
%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}\Ue725 %{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%} ✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}"
