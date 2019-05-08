#!/bin/bash

HOME_DIR=$1
PLATFORM_DIR=$(pwd)
SHARED_DIR=${PLATFORM_DIR}/../shared

mkdir -p /usr/local/bin
mkdir -p /usr/local/sbin

chown -R $USER /usr/local/bin
chown -R $USER /usr/local/sbin

export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

brew update && brew upgrade
brew tap homebrew/cask-versions
brew tap homebrew/cask-drivers
brew tap homebrew/cask-fonts

# install npm
brew install node
npm config set prefix "${HOME_DIR}/.npm-global"

# install cli tools
brew install \
  curl \
  bash \
  fish \
  git \
  gnupg \
  openssl \
  the_silver_searcher \
  firebase-cli

# install languages
brew install go ruby python

# install applications
brew cask install \
  caffeine \
  visual-studio-code \
  spotify \
  slack \
  google-chrome \
  bettertouchtool \
  bitwarden \
  docker \
  keybase

brew update && brew cleanup && brew cleanup

# install fish
if ! grep -q "fish" /etc/shells; then
  echo "/usr/local/bin/fish" | sudo tee -a /etc/shells
  chsh -s /usr/local/bin/fish
fi
