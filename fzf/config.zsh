# Config for command line fuzzy finder fzf
# https://github.com/junegunn/fzf

local fzfroot="$HOME/.dotfiles/fzf/fzf"

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
