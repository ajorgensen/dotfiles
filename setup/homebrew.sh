#!/usr/bin/env bash

# Check to see if Homebrew is already installed
if command -v brew &> /dev/null; then
  echo "Homebrew is already installed. Skipping..."
  exit 0
fi

eval(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)
