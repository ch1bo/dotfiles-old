autoload colors && colors

if (( $+commands[git] ))
then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

git_branch() {
  branch=$($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})
  if [[ $branch != "" ]]
  then
    echo "($branch)"
  fi
}

# git_dirty() {
#   if $(! $git status -s &> /dev/null)
#   then
#     echo ""
#   else
#     if [[ $($git status --porcelain) == "" ]]
#     then
#       echo "on %{$fg_bold[green]%}$(git_branch)%{$reset_color%}"
#     else
#       echo "on %{$fg_bold[red]%}$(git_branch)%{$reset_color%}"
#     fi
#   fi
# }

# git_branch() {
#  ref=$($git symbolic-ref HEAD 2>/dev/null) || return
#  echo "${ref#refs/heads/}"
# }

# git_unpushed() {
#   unpushed=$($git cherry -v @{upstream} 2>/dev/null) || return
#   if [[ $(unpushed) == "" ]]
#   then
#     echo " "
#   else
#     echo " %{$fg_bold[red]%}unpushed%{$reset_color%}"
#   fi
# }

user() {
  echo "%{$fg_bold[magenta]%}%n%{$reset_color%}"
}

host() {
  echo "%{$fg_bold[green]%}%m%{$reset_color%}"
}

directory_name() {
  echo "%{$fg_bold[cyan]%}%1/%\%{$reset_color%}"
}

export PROMPT=$'$(user)@$(host):$(directory_name)$(git_branch) > '
export RPROMPT="%{$fg_bold[grey]%}%t%{$reset_color%}"
