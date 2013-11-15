#!/bin/bash

symlink() {
  [ -L $2 ] && (rm $2; echo " rm $2"); ln -s $1 $2
  printf " ln -s $1 $2\n\n"
}

declare -a dotfiles=(
"zshrc",
"zsh",
"config/fish",
"gitignore",
"vim",
"vimrc"
"tmux.conf")

if [[ $1 == 'osx' ]]; then
  echo "Configuring OSX"
elif [[ $1 == 'linux' ]]; then
  echo "Configuring Linux"
fi
  

for i in "${!dotfiles[@]}"; do
  echo ${dotfiles[$i]}
  symlink "$(pwd)/${dotfiles[$i]}" ~/.${dotfiles[$i]}
done
