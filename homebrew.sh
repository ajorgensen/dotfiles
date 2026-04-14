#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)"

if command -v brew >/dev/null 2>&1; then
  BREW_BIN="$(command -v brew)"
  echo "Homebrew is already installed. Skipping..."
else
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if command -v brew >/dev/null 2>&1; then
    BREW_BIN="$(command -v brew)"
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    BREW_BIN="/opt/homebrew/bin/brew"
  elif [[ -x /usr/local/bin/brew ]]; then
    BREW_BIN="/usr/local/bin/brew"
  else
    echo "Homebrew install completed, but brew was not found on PATH." >&2
    exit 1
  fi
fi

eval "$("$BREW_BIN" shellenv)"
"$BREW_BIN" bundle --file "$SCRIPT_DIR/Brewfile"
