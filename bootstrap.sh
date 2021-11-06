#!/usr/bin/env bash

info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

link_file () {
  local src=$1 dst=$2
  local currentSrc="$(readlink $dst)"

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
  then
    if [ "$currentSrc" == "$src" ]
    then
      info "Skipping $src because it is the same as $dst"
      return
    else
      mv "$dst" "${dst}.backup"
      success "moved $dst to ${dst}.backup"
    fi
  fi

  ln -s "$1" "$2"
  success "linked $1 to $2"
}

link_dotfile() {
  local overwrite_all=false backup_all=false skip_all=false

  src=$(pwd -P)/$1
  #dst="$HOME/$1"
  dst="$HOME/$1"

  link_file $src $dst
}

link_dotfile .ackrc
link_dotfile .config/fish
link_dotfile .gemrc
link_dotfile .gitconfig
link_dotfile .gitignore
link_dotfile .tmux.conf
link_dotfile .vim
link_dotfile .vimrc
link_dotfile .zsh
link_dotfile .zshenv
link_dotfile .zshrc
link_dotfile bin
