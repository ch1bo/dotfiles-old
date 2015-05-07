# Config/install file for z (https://github.com/rupa/z)

# Add man page if necessary
if [[ ! "$MANPATH" =~ "$ZSH/z/man" && -d "$ZSH/z/man" ]]; then
  export MANPATH="$MANPATH:$ZSH/z/man"
fi

source $ZSH/z/z/z.sh
