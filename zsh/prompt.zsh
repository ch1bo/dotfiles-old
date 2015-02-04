autoload colors && colors

# Context: user@hostname
prompt_context() {
  local context=%{$fg_bold[green]%}%n%{$reset_color%}
  if [[ -n "$SSH_CONNECTION" ]]; then
    context=$context%{$fg_bold[magenta]%}@%m%{$reset_color%}
  fi
  echo $context
}

# Dir: current working directory
prompt_dir() {
  echo %{$fg_bold[blue]%}%~%{$reset_color%}
  # echo %{$fg_bold[blue]%}%1/%{$reset_color%}
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
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}$CROSS"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}$LIGHTNING"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}$GEAR"

  [[ -n "$symbols" ]] && prompt_segment $PRIMARY_FG default " $symbols "
}

function prompt_ch1bo_setup {
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

  export PROMPT="$(prompt_context) $(prompt_dir) ➔  "
  # RPROMPT='${editor_info[overwrite]}%(?:: %F{red}⏎%f)${VIM:+" %B%F{green}V%f%b"}${INSIDE_EMACS:+" %B%F{green}E%f%b"}${git_info[rprompt]}'
  # SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '
}

prompt_ch1bo_setup "$@"
