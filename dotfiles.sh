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

# Link individual files; keep private extensions and runtime state outside the repo.
stow --no-folding --target="$HOME" hunk maki pi

# pi writes runtime state (deviceId, lastChangelogVersion) into its settings,
# so merge the tracked keys into the local file instead of linking it.
pi_settings="$HOME/.pi/agent/settings.json"
if [ -L "$pi_settings" ]; then
  rm "$pi_settings"
fi
if [ -f "$pi_settings" ]; then
  jq -s '.[0] * .[1]' "$pi_settings" pi/.pi/agent/settings.json >"$pi_settings.tmp"
  mv "$pi_settings.tmp" "$pi_settings"
else
  mkdir -p "$(dirname "$pi_settings")"
  cp pi/.pi/agent/settings.json "$pi_settings"
fi

go install ./cmd/epoch
"$SCRIPT_DIR/agents/sync.sh"
