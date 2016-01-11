# Stash your environment variables in ~/.env.zsh. This means they'll stay out
# of your main dotfiles repository (which may be public, like this one), but
# you'll have access to them in your scripts.
if [[ -a ~/.env.zsh ]]; then
  source ~/.env.zsh
fi

