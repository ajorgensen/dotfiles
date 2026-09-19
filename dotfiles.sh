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
  workmux \
  worktrunk \
  zsh

# Keep Hunk's private extensions and runtime state outside the repo.
stow --no-folding --target="$HOME" hunk

go install ./cmd/epoch
"$SCRIPT_DIR/agents/sync.sh"
