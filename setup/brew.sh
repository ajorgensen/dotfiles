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
brew install gnupg
brew install golang
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
brew install r
brew install rbenv
brew install reattach-to-user-namespace
brew install rename
brew install rsync
brew install ruby-install
brew install selecta
brew install svn
brew install tig
brew install tmux
brew install tokei
brew install tree
brew install vim
brew install wget
brew install zsh

# Source code Pro
brew Tap homebrew/cask-fonts && brew install --cask font-source-code-pro

# Apps
brew install --cask alfred
brew install --cask bettertouchtool
brew install --cask bitwarden
brew install --cask caffeine
brew install --cask discord
brew install --cask docker
brew install --cask iterm2
brew install --cask keybase
brew install --cask macdown
brew install --cask obsidian
brew install --cask rstudio
brew install --cask slack
brew install --cask spotify
brew install --cask todoist
brew install --cask visual-studio-code
brew install --cask vlc
brew install --cask gpg-suite-no-mail
