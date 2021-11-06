#!/usr/bin/env bash

set -e

if ! command -v brew &> /dev/null
then
  echo "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install reattach-to-user-namespace \
  git \
  zsh \
  vim \
  ruby-install \
  tmux \
  wget \
  fswatch \
  ag \
  postgresql \
  lame \
  python3 \
  pngquant \
  ghc \
  multimarkdown \
  graphviz \
  offlineimap \
  tree \
  lua \
  colordiff \
  hub \
  chruby \
  jpeg \
  selecta \
  par2 \
  tokei \
  diff-so-fancy \
  dust \
  tig \
  fd \
  nvm \
  htop \
  md5sha1sum \
  coreutils \
  pstree \
  rsync \
  imagemagick \
  ffmpeg

brew install --HEAD https://raw.github.com/postmodern/gem_home/master/homebrew/gem_home.rb
brew tap heroku/brew && brew install heroku

# Don't animate windows opening. This is different from applications opening.
# This applies when, for example, you have a running instance of Chrome or
# TextEdit and hit Cmd-N.
#
# Last verified working: 2020-04-27
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool NO
