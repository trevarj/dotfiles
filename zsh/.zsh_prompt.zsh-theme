#!/bin/zsh

autoload -Uz colors vcs_info
colors
zmodload zsh/datetime 2>/dev/null

# Allow prompt variables such as $vcs_info_msg_0_ to refresh before each draw.
setopt prompt_subst

# Git status via zsh's vcs_info.
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
zstyle ':vcs_info:git:*' stagedstr ' %F{green}●%f'
zstyle ':vcs_info:git:*' unstagedstr ' %F{yellow}●%f'
zstyle ':vcs_info:git:*' formats ' %F{8}on%f %F{10} %b%f%c%u%m'
zstyle ':vcs_info:git:*' actionformats ' %F{8}on%f %F{10} %b%f%c%u%m'

typeset -g prompt_command_started_at=''
typeset -g prompt_elapsed_info=''
typeset -g prompt_exit_info=''
typeset -g prompt_git_state_info=''
typeset -g prompt_guix_info=''
typeset -g prompt_guix_cached_env=''
typeset -g prompt_guix_cached_info=''
typeset -g prompt_first_line=''
typeset -g prompt_right_info=''
typeset -g prompt_symbol='%F{10}➜%f'

+vi-git-untracked() {
  local -a git_status

  git_status=("${(@f)$(command git status --porcelain --untracked-files=normal 2>/dev/null)}")
  if (( ${git_status[(I)\?\?*]} )); then
    hook_com[misc]+=' %F{12}●%f'
  fi
}

dotfiles_prompt_preexec() {
  prompt_command_started_at=${EPOCHREALTIME:-$SECONDS}
}

dotfiles_prompt_elapsed_info() {
  prompt_elapsed_info=''

  if [[ -z ${prompt_command_started_at} ]]; then
    return
  fi

  local now=${EPOCHREALTIME:-$SECONDS}
  local elapsed=$(( now - prompt_command_started_at ))
  prompt_command_started_at=''

  if (( elapsed < 2 )); then
    return
  fi

  local elapsed_display
  if (( elapsed >= 60 )); then
    local -i minutes=$(( elapsed / 60 ))
    local -i seconds=$(( elapsed - (minutes * 60) ))
    printf -v elapsed_display '%dm%02ds' ${minutes} ${seconds}
  else
    printf -v elapsed_display '%.1fs' ${elapsed}
  fi

  prompt_elapsed_info=" %F{13}took ${elapsed_display}%f"
}

dotfiles_prompt_exit_info() {
  local last_status=$1

  prompt_exit_info=''
  if (( last_status != 0 )); then
    prompt_exit_info=" %F{9}exit ${last_status}%f"
    prompt_symbol='%F{9}➜%f'
  else
    prompt_symbol='%F{10}➜%f'
  fi
}

dotfiles_prompt_git_state_info() {
  prompt_git_state_info=''

  local git_dir
  git_dir=$(command git rev-parse --git-dir 2>/dev/null) || return

  if [[ -f ${git_dir}/MERGE_HEAD ]]; then
    prompt_git_state_info=' %F{9}merge%f'
  elif [[ -d ${git_dir}/rebase-merge || -d ${git_dir}/rebase-apply ]]; then
    prompt_git_state_info=' %F{9}rebase%f'
  elif [[ -f ${git_dir}/CHERRY_PICK_HEAD ]]; then
    prompt_git_state_info=' %F{9}cherry-pick%f'
  elif [[ -f ${git_dir}/REVERT_HEAD ]]; then
    prompt_git_state_info=' %F{9}revert%f'
  elif [[ -f ${git_dir}/BISECT_LOG ]]; then
    prompt_git_state_info=' %F{13}bisect%f'
  fi
}

dotfiles_prompt_guix_info() {
  prompt_guix_info=''

  if [[ -z ${GUIX_ENVIRONMENT:-} ]]; then
    prompt_guix_cached_env=''
    prompt_guix_cached_info=''
    return
  fi

  if [[ ${prompt_guix_cached_env} == ${GUIX_ENVIRONMENT} ]]; then
    prompt_guix_info=${prompt_guix_cached_info}
    return
  fi

  local guix_env_name=${GUIX_ENVIRONMENT:t}
  local guix_packages=''

  if [[ -r ${GUIX_ENVIRONMENT}/manifest ]]; then
    local manifest_text
    local -a manifest_entries

    manifest_text="$(<${GUIX_ENVIRONMENT}/manifest)"
    manifest_entries=("${(@s:(manifest-entry:)manifest_text}")
    local guix_package_count=$(( ${#manifest_entries} - 1 ))
    guix_packages=" %F{8}${guix_package_count}p%f"
  fi

  prompt_guix_cached_env=${GUIX_ENVIRONMENT}
  prompt_guix_cached_info=" %F{11} %f%F{8}${guix_env_name}%f${guix_packages}"
  prompt_guix_info=${prompt_guix_cached_info}
}

dotfiles_prompt_visible_length() {
  emulate -L zsh
  setopt extended_glob

  local expanded=${(%)1}
  expanded=${expanded//$'\e'\[[0-9\;]##m/}
  print -r -- ${#expanded}
}

dotfiles_prompt_first_line() {
  local left="${prompt_path}${vcs_info_msg_0_}"
  local right=${prompt_guix_info# }

  if [[ -z ${right} ]]; then
    prompt_first_line=${left}
    return
  fi

  local left_width=$(dotfiles_prompt_visible_length ${left})
  local right_width=$(dotfiles_prompt_visible_length ${right})
  local gap=$(( COLUMNS - left_width - right_width ))

  if (( gap < 1 )); then
    prompt_first_line="${left} ${right}"
    return
  fi

  local padding="${(l:${gap}:: :)}"
  prompt_first_line="${left}${padding}${right}"
}

dotfiles_prompt_precmd() {
  local last_status=$?

  dotfiles_prompt_elapsed_info
  dotfiles_prompt_exit_info ${last_status}
  vcs_info
  dotfiles_prompt_git_state_info
  dotfiles_prompt_guix_info

  dotfiles_prompt_first_line
  prompt_right_info="${prompt_exit_info}${prompt_elapsed_info}${prompt_git_state_info}"
}

# Avoid stacking duplicate hooks when this file is sourced repeatedly.
if [[ -z ${preexec_functions[(r)dotfiles_prompt_preexec]} ]]; then
  preexec_functions+=(dotfiles_prompt_preexec)
fi

if [[ -z ${precmd_functions[(r)dotfiles_prompt_precmd]} ]]; then
  precmd_functions+=(dotfiles_prompt_precmd)
fi

prompt_path='%B%F{12}%~%f%b'

PROMPT='${prompt_first_line}
${prompt_symbol} '
RPROMPT='${prompt_right_info}'
