#!/usr/bin/env bash

set -euo pipefail

# setup
export XDG_CONFIG_HOME="$HOME/.config"

# link all the things
ln -sf "$PWD/alacritty" "$XDG_CONFIG_HOME"
ln -sf "$PWD/tmux" "$XDG_CONFIG_HOME"
ln -sf "$PWD/nvim" "$XDG_CONFIG_HOME"

ln -sf "$PWD/git/gitignore" "$HOME/.gitignore"
ln -sf "$PWD/git/gitconfig" "$HOME/.gitconfig"

# ~~~~~ OSX related configuration ~~~~~
if [ "$(uname -s)" == "Darwin" ]; then
    ln -sf "$PWD/Rectangle" "$HOME/Library/Application Support"
fi
