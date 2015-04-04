if command -v npm >/dev/null 2>&1; then
  eval "$(npm completion)"
fi
if command -v grunt >/dev/null 2>&1; then
  eval "$(grunt --completion=zsh)"
fi
