#!/usr/bin/env bash

# Check to see if Homebrew is already installed
if command -v brew &>/dev/null; then
  echo "Homebrew is already installed. Skipping..."
else
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew bundle
