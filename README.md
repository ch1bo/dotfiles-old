# Home sweet ~/

## dotfiles

These are my dotfiles, forked from Zach Holman and customized to my needs.

So far I have only customized the bootstrap script to handle hierarchy of
symlinked folders correctly in the topic folders. Also all OS X relevant stuff
was removed.

If you're interested in the philosophy behind why projects like these are
awesome, you might want to [read his post on the
subject](http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/).

## install

Run this:

```sh
git clone https://github.com/ch1bo/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

This will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

The main file you'll want to change right off the bat is `zsh/zshrc.symlink`,
which sets up a few paths that'll be different on your particular machine.

Environment variables which should not be versioned in this git repository
(i.e. only relevant for certain environments/machines you are on) can go into
`~/env.sh`.

## topical

Everything's built around topic areas. If you're adding a new area to your
forked dotfiles — say, "Java" — you can simply add a `java` directory and put
files in there. Anything with an extension of `.zsh` will get automatically
included into your shell. Anything with an extension of `.symlink` will get
symlinked without extension into `$HOME` when you run `script/bootstrap`.

The symlinking was slightly adapted to also support linking `.symlink` files from
within a folder hierarchy. This means that, for example, the terminator config
locatd at `terminator/config/terminator/config.symlink` will get symlinked from
`~/.config/terminator/config`.

## what's inside

My zsh configurations, prompt and functions, as well configuration files for tools
in my use. As I only discovered dotfile repositories recently, I am constantly
moving stuff into this repo.

## components

There's a few special files in the hierarchy.

- **bin/**: Anything in `bin/` will get added to your `$PATH` and be made
  available everywhere.
- **topic/\*.zsh**: Any files ending in `.zsh` get loaded into your
  environment.
- **topic/path.zsh**: Any file named `path.zsh` is loaded first and is
  expected to setup `$PATH` or similar.
- **topic/completion.zsh**: Any file named `completion.zsh` is loaded
  last and is expected to setup autocomplete.
- **topic/\*\*/\*.symlink**: Any files ending in `*.symlink` get symlinked
  into   your `$HOME` (at the corresponding path). This is so you can keep all
  of those versioned in your dotfiles   but still keep those autoloaded files in
  your home directory. These get   symlinked in when you run `script/bootstrap`.

## bugs

No guarantee that this repo will always work for you. I do use this as *my*
dotfiles, so there's a good chance I may break something if I forget to make a
check for a dependency.
