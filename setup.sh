#!/bin/bash

function success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

function error () {
  printf "\r\033[2K  [\033[0;31mError\033[0m] $1\n"
}

function link_file() {
  local src=$(realpath $1) dst=$2
  local currentSrc="$(readlink $dst)"

  if [ "$currentSrc" == "$src" ]; then
    success "$src is already linked. Skipping."
    return
  fi

  if [ ! -e "$src" ]; then
    error "Source $src does not exist."
    return 
  fi

  if [ -e "$dst" ] || [ -h "$dst" ]; then
    error "Destination $dst already exists."
    return
  fi

  ln -s $src $dst
  success "Linked $src to $dst"
}

function link_dotfile() {
  local src=$(realpath $1)
  local dst_folder=${2:-$HOME} 
  local dotfile_name=$(basename $src)
  local dst="$dst_folder/$dotfile_name"

  link_file $src $dst
}

link_dotfile .ackrc
link_dotfile .fish
link_dotfile .gemrc
link_dotfile .gitconfig
link_dotfile .gitignore
link_dotfile .gitmodules
link_dotfile .tmux.conf
link_dotfile .vim
link_dotfile .vimrc
link_dotfile .zshrc
link_dotfile .zprofile
link_dotfile .zsh
link_dotfile .zshenv
link_dotfile bin
