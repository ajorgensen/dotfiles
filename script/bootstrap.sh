#!/usr/bin/env bash
# Shamelessly stolen from Zach Holman (https://github.com/holman/dotfiles/blob/master/script/bootstrap)

cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd)

# Exit immediately if command exits with non-zero status
set -e

function info () {
  if [ -n "$1" ]
  then
    IN="$1"
  else
    read IN # This reads a string from stdin and stores it in a variable called IN
  fi

  printf "  [ \033[00;34m..\033[0m ] $IN\n"
}

user () {
  printf "\r  [ \033[0;33m?\033[0m ] $1 "
}

function success () {
  if [ -n "$1" ]
  then
    IN="$1"
  else
    read IN # This reads a string from stdin and stores it in a variable called IN
  fi

  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $IN\n"
}

function fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  exit
}

link_file () {
  local src=$1 dst=$2

  local overwrite= backup= skip=
  local action=

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
  then

    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
    then

      local currentSrc="$(readlink $dst)"

      if [ "$currentSrc" == "$src" ]
      then

        skip=true;

      else

        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac

      fi

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      success "removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      mv "$dst" "${dst}.backup"
      success "moved $dst to ${dst}.backup"
    fi

    if [ "$skip" == "true" ]
    then
      success "skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]  # "false" or empty
  then
    ln -s "$1" "$2"
    success "linked $1 to $2"
  fi
}

function install_dotfiles() {
  info "Installing dotfiles"

  local overwrite_all=false backup_all=false skip_all=false

  for src in $(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink'); do
    dst="$HOME/.$(basename "${src%.*}")"
    #dst="/tmp/dotfiles/.$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done

  success "Finished installing dotfiles"
}

function install_packages() {
  info "Installing packages"
  platform=$(uname -s)

  for package in $(find -H "$DOTFILES_ROOT/packages/$platform" -name "*.install"); do
    sh -c "$package" | success
  done
}

install_dotfiles
info " "
install_packages

info "All done"
