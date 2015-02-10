autoload colors && colors

# Context: user@hostname
prompt_context() {
  local context
  context+=%{$fg_bold[black]%}[%{$reset_color%}
  context+=%{$fg_bold[green]%}%n%{$reset_color%}
  if [[ -n "$SSH_CONNECTION" ]]; then
    context=$context%{$fg_bold[magenta]%}@%m%{$reset_color%}
  fi
  context+=%{$fg_bold[black]%}]%{$reset_color%}
  echo "$context"
}

# Dir: current working directory
prompt_dir() {
  local dir
  dir+=%{$fg_bold[black]%}[%{$reset_color%}
  dir+=%{$fg_bold[blue]%}%~%{$reset_color%}
  dir+=%{$fg_bold[black]%}]%{$reset_color%}
  echo "$dir"
}

# Git: branch/detached head, dirty status
prompt_git() {
  local color ref
  is_dirty() {
    test -n "$(git status --porcelain --ignore-submodules)"
  }
  ref="$vcs_info_msg_0_"
  if [[ -n "$ref" ]]; then
    if is_dirty; then
      color=yellow
      ref="${ref} $PLUSMINUS"
    else
      color=green
      ref="${ref} "
    fi
  if [[ "${ref/.../}" == "$ref" ]]; then
    ref="$BRANCH $ref"
  else
    ref="$DETACHED ${ref/.../}"
  fi
  prompt_segment $color $PRIMARY_FG
  print -Pn " $ref"
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{$fg_bold[red]%}✘ "
  [[ $UID -eq 0 ]] && symbols+="%{$fg_bold[yellow]%}⚡ "
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{$fg_bold[cyan]%}⚙ "
  echo "$symbols%{$reset_color%}"
}

set_prompt() {
  local symbols
  symbols=()
  symbols+="✚ ⬆ ⬇ ✖ ✱ ➜ ✨ ═ ◼ ±  ➦ ✔ ✘ ❤ ⚡ ⚙ ➭"
  symbols+="★ ❗ ⌥ ⎇  ⊢ ☢ ♻ ☀ ☁ ☔ ❄ "
  # Arrows
  symbols+="∝ ⌁ ♯ ≈ ➟ ➩ ➪ ⤳ ➟ ➤ ⇢ ➦ "

  # echo $symbols
  # for c in $fg; do
  #   echo $c"normal"$reset_color
  # done
  # for c in $fg_bold; do
  #   echo $c"bold"$reset_color
  # done

  export PROMPT="$(prompt_context)$(prompt_dir)$(prompt_status)%{$fg_bold[  white]%} ➜  %{$reset_color%}"
  # RPROMPT="%{$fg_bold[red]%}❤ Bianca❤%{$reset_color%}"
  # SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '
}

precmd() {
  title "zsh" "zsh - %n@%m" ""
  set_prompt
}
