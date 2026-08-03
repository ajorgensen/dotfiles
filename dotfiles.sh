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
  herdr \
  nvim \
  tmux \
  wezterm \
  zsh

"$SCRIPT_DIR/agents/sync.sh"
