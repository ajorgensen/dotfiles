#!/usr/bin/env bash

set -e

if ! command -v brew &> /dev/null
then
  echo "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew update

brew install ag
brew install chruby
brew install colordiff
brew install coreutils
brew install coreutils
brew install diff-so-fancy
brew install dust
brew install fd
brew install ffmpeg
brew install findutils
brew install fswatch
brew install ghc
brew install git
brew install git-lfs
brew install graphviz
brew install grep
brew install htop
brew install hub
brew install imagemagick
brew install jpeg
brew install lame
brew install lua
brew install md5sha1sum
brew install multimarkdown
brew install nvm
brew install offlineimap
brew install par2
brew install pngquant
brew install postgresql
brew install pstree
brew install python3
brew install reattach-to-user-namespace
brew install rename
brew install rsync
brew install ruby-install
brew install selecta
brew install tig
brew install tmux
brew install tokei
brew install tree
brew install vim
brew install wget
brew install zsh

brew install --HEAD https://raw.github.com/postmodern/gem_home/master/homebrew/gem_home.rb
brew tap heroku/brew && brew install heroku

# Source code Pro
brew Tap homebrew/cask-fonts && brew install --cask font-source-code-pro

# Don't animate windows opening. This is different from applications opening.
# This applies when, for example, you have a running instance of Chrome or
# TextEdit and hit Cmd-N.
#
# Last verified working: 2020-04-27
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool NO
