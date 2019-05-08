#!/bin/bash

HOME_DIR=$1
PLATFORM_DIR=$(pwd)
SHARED_DIR=$(pwd)/../shared
FISH_DIR=${HOME_DIR}/.config/fish
GPG_DIR=${HOME_DIR}/.gnupg

set -e
. ${PLATFORM_DIR}/../common.sh

echo "----------------------------------------------"
echo "=> Home Directory: $HOME_DIR"
echo "=> Platform Directory: $PLATFORM_DIR"
echo "=> Shared Directory: $SHARED_DIR"
echo "=> Fish Directory: $FISH_DIR"
echo "=> GPG Directory: $GPG_DIR"
echo "----------------------------------------------"

overwrite_all=false backup_all=false skip_all=false

# git config
info "Symlink git Configuration"
link_file ${SHARED_DIR}/gitconfig ${HOME_DIR}/.gitconfig
link_file ${SHARED_DIR}/gitignore ${HOME_DIR}/.gitignore

# fish config
info "Symlink fish Configuration"
mkdir -p ${HOME_DIR}/.config/fish
link_file ${SHARED_DIR}/fish ${HOME_DIR}/.config/fish

# tmux config
info "Symlink tmux Configuration"
link_file ${SHARED_DIR}/tmux.conf ${HOME_DIR}/.tmux.conf

# vim config
info "Symlink vim Configuration"
mkdir -p ${HOME_DIR}/.vim
link_file ${SHARED_DIR}/vimrc ${HOME_DIR}/.vimrc
link_file ${SHARED_DIR}/vim ${HOME_DIR}/.vim

# zsh config
info "Symlink zsh Configuration"
mkdir -p ${HOME_DIR}/.zsh
link_file ${SHARED_DIR}/zshrc ${HOME_DIR}/.zshrc
link_file ${SHARED_DIR}/zsh ${HOME_DIR}/.zsh

# bin
info "Symlink bin"
mkdir -p ${HOME_DIR}/bin
link_file ${SHARED_DIR}/bin ${HOME_DIR}/bin
