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

  if [ -e "$dst" ]; then
    error "Destination $dst already exists."
    return
  fi

  ln -s $src $dst
  success "Linked $src to $dst"
}

link_file .ackrc $HOME/.ackrc
link_file .fish $HOME/.fish
link_file .gemrc $HOME/.gemrc
link_file .gitconfig $HOME/.gitconfig
link_file .gitignore $HOME/.gitignore
link_file .gitmodules $HOME/.gitmodules
link_file .tmux.conf $HOME/.tmux
link_file .vim $HOME/.vim
link_file .vimrc $HOME/.vimrc
link_file .zshrc $HOME/.zshrc
link_file .zprofile $HOME/.zprofile
link_file .zsh $HOME/.zsh
link_file .zshenv $HOME/.zshenv
link_file bin $HOME/bin
