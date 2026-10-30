#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)"

cd "$SCRIPT_DIR"

stow --target="$HOME" \
  ack \
  scripts \
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

# Link individual files; keep private extensions and runtime state outside the repo.
stow --no-folding --target="$HOME" maki

go install ./cmd/epoch
"$SCRIPT_DIR/agents/sync.sh"
