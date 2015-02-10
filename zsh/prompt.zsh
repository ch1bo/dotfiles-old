autoload colors && colors

function colors() {
  echo "256 colors"
  for i in {0..255} ; do
    echo "\x1b[38;5;${i}mcolour${i}"
  done
  echo "Solarized colors"
  echo "$fg_bold[black]base03$reset_color"
  echo "$fg[black]base02$reset_color"
  echo "$fg_bold[green]base01$reset_color"
  echo "$fg_bold[yellow]base00$reset_color"
  echo "$fg_bold[blue]base0$reset_color"
  echo "$fg_bold[cyan]base1$reset_color"
  echo "$fg[white]base2$reset_color"
  echo "$fg_bold[white]base3$reset_color"
  echo "$fg[yellow]yellow$reset_color"
  echo "$fg_bold[red]orange$reset_color"
  echo "$fg[red]red$reset_color"
  echo "$fg[magenta]magenta$reset_color"
  echo "$fg_bold[magenta]violet$reset_color"
  echo "$fg[blue]blue$reset_color"
  echo "$fg[cyan]cyan$reset_color"
  echo "$fg[green]green$reset_color"
}

# Context: user@hostname
prompt_context() {
  local context
  context+=%{$fg_bold[green]%}[%{$reset_color%}
  context+=%{$fg_bold[magenta]%}%n%{$reset_color%}
  if [[ -n "$SSH_CONNECTION" ]]; then
    context=$context%{$fg[yellow]%}@%m%{$reset_color%}
  fi
  context+=%{$fg_bold[green]%}]%{$reset_color%}
  echo "$context"
}

# Dir: current working directory
prompt_dir() {
  local dir
  dir+=%{$fg_bold[green]%}[%{$reset_color%}
  dir+=%{$fg[blue]%}%~%{$reset_color%}
  dir+=%{$fg_bold[green]%}]%{$reset_color%}
  echo "$dir"
}

# Git: branch/detached head, dirty status
prompt_git() {
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
  echo "$symbols%{$reset_color%}"
}

set_prompt() {
  local symbols
  symbols=()
  symbols+="✚ ⬆ ⬇ ✖ ✱ ➜ ✨ ═ ◼ ±  ➦ ✔ ✘ ❤ ⚡ ⚙ ➭"
  symbols+="★ ❗ ⌥ ⎇  ⊢ ☢ ♻ ☀ ☁ ☔ ❄ "
  # Arrows
  symbols+="∝ ⌁ ♯ ≈ ➟ ➩ ➪ ⤳ ➟ ➤ ⇢ ➦ "

  export PROMPT="$(prompt_context)$(prompt_dir)$(prompt_status)%{$fg_bold[  white]%} ➜  %{$reset_color%}"
  # RPROMPT="%{$fg_bold[red]%}❤ Bianca❤%{$reset_color%}"
  # SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '
}

precmd() {
  title "zsh" "zsh - %n@%m" ""
  set_prompt
}
