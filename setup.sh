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
ln -sf "$PWD/ack/ackrc" "$HOME/.ackrc"

ln -sf "$PWD/zsh/zsh" "$HOME/.zsh"
ln -sf "$PWD/zsh/zsh_profile" "$HOME/.zsh_profile"
ln -sf "$PWD/zsh/zshenv" "$HOME/.zshenv"
ln -sf "$PWD/zsh/zshrc" "$HOME/.zshrc"

ln -sf "$PWD/bin/bin" "$HOME/.local/bin"

# ~~~~~ OSX related configuration ~~~~~
if [ "$(uname -s)" == "Darwin" ]; then
    ln -sf "$PWD/Rectangle" "$HOME/Library/Application Support"
fi
