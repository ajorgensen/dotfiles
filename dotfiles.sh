#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)"

cd "$SCRIPT_DIR"

stow --target="$HOME" \
  ack \
  bin \
  git \
  ghostty \
  hammerspoon \
  nvim \
  opencode \
  pi \
  tmux \
  wezterm \
  zsh
