# Config for command line fuzzy finder fzf
# https://github.com/junegunn/fzf

local fzfroot="$HOME/.dotfiles/fzf/fzf/"
if [[ ! -f "$fzfroot/bin/fzf" ]]; then
  return
fi

# Setup fzf
# ---------
if [[ ! "$PATH" =~ "$fzfroot/bin" ]]; then
  export PATH="$PATH:$fzfroot/bin"
fi

# Man path
# --------
if [[ ! "$MANPATH" =~ "$fzfroot/man" && -d "$fzfroot/man" ]]; then
  export MANPATH="$MANPATH:$fzfroot/man"
fi

# Auto-completion
# ---------------
#[[ $- =$HOME i ]] && source "$HOME/.fzf/shell/completion.zsh"

# Key bindings
# ------------
source "$fzfroot/shell/key-bindings.zsh"
