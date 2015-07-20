autoload colors && colors
autoload -Uz vcs_info

# Context: user@hostname
prompt_context() {
  local context
  context+=%{$fg_bold[black]%}[%{$reset_color%}
  context+=%{$fg_bold[magenta]%}%n%{$reset_color%}
  if [[ -n "$SSH_CONNECTION" ]]; then
    context=$context%{$fg[yellow]%}@%m%{$reset_color%}
  fi
  context+=%{$fg_bold[black]%}]%{$reset_color%}
  echo "$context"
}

# Dir: current working directory
prompt_dir() {
  local dir
  dir+=%{$fg_bold[black]%}[%{$reset_color%}
  dir+=%{$fg[blue]%}%~%{$reset_color%}
  dir+=%{$fg_bold[black]%}]%{$reset_color%}
  echo "$dir"
}

# Git: using vcs_info

prompt_git_formats() {
  echo "%{$fg[cyan]%}⎇ %b%{$reset_color%}"
}

prompt_git_actionformats() {
  local str="$(prompt_git_formats)" # extend normal format
  str+="%{$fg_bold[black]%}|%{$reset_color%}" # separator
  str+="%{$fg[yellow]%}%a%{$reset_color%}"
  echo str
}

zstyle ":vcs_info:*" enable git
zstyle ":vcs_info:*" formats "$(prompt_git_formats)"
zstyle ":vcs_info:*" actionformats "$(prompt_git_actionformats)"

prompt_git() {
  if [[ -n $vcs_info_msg_0_ ]]; then
    local str=""
    str+="%{$fg_bold[black]%}[%{$reset_color%}"
    str+="$vcs_info_msg_0_"
    str+="%{$fg_bold[black]%}]%{$reset_color%}"
    echo $str
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{$fg[red]%}✘ "
  [[ $UID -eq 0 ]] && symbols+="%{$fg_bold[red]%}⚡ "
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{$fg[cyan]%}⚙ "  
  # Only print if anything to display
  if test ${#symbols[@]} -gt 0; then
    local str=""
    str+="%{$fg_bold[black]%}[%{$reset_color%}"
    str+="$symbols%{$reset_color%}"
    str+="%{$fg_bold[black]%}]%{$reset_color%}"
    echo $str
  fi
}

set_prompt() {
  # local symbols
  # symbols=()
  # symbols+="✚ ⬆ ⬇ ✖ ✱ ➜ ✨ ═ ◼ ±  ➦ ✔ ✘ ❤ ⚡ ⚙ ➭"
  # symbols+="★ ❗ ⌥ ⎇  ⊢ ☢ ♻ ☀ ☁ ☔ ❄ "
  # Arrows
  # symbols+="∝ ⌁ ♯ ≈ ➟ ➩ ➪ ⤳ ➟ ➤ ⇢ ➦ "

  export PROMPT="$(prompt_context)$(prompt_dir)$(prompt_git)$(prompt_status)%{$fg[magenta]%} ➜ %{$reset_color%}"
  # RPROMPT="%{$fg_bold[red]%}❤ Bianca❤%{$reset_color%}"
  # SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '
}

precmd() {
  title "zsh" "zsh - %n@%m" ""
  vcs_info
  set_prompt
}

