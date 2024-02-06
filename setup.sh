#!/usr/bin/env bash

set -euo pipefail

# setup
export XDG_CONFIG_HOME="$HOME/.config"

# link all the things
ln -sf "$PWD/alacritty" "$XDG_CONFIG_HOME"
ln -sf "$PWD/tmux" "$XDG_CONFIG_HOME"
