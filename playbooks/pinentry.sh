#!/usr/bin/env bash

set -euo pipefail

PINENTRY_PATH=""

if command -v brew >/dev/null 2>&1; then
    PINENTRY_PATH="$(brew --prefix)/bin/pinentry-mac"
elif [[ -x /opt/homebrew/bin/pinentry-mac ]]; then
    PINENTRY_PATH="/opt/homebrew/bin/pinentry-mac"
elif [[ -x /usr/local/bin/pinentry-mac ]]; then
    PINENTRY_PATH="/usr/local/bin/pinentry-mac"
fi

if [[ -z "$PINENTRY_PATH" ]]; then
    echo "pinentry-mac was not found." >&2
    exit 1
fi

# Check if the gpg-agent.conf file exists
if [ ! -d ~/.gnupg ]; then
    mkdir -p ~/.gnupg
    chmod 700 ~/.gnupg
fi

# Check if pinentry-program is already configured
if grep -q "^pinentry-program $PINENTRY_PATH\$" ~/.gnupg/gpg-agent.conf 2>/dev/null; then
    echo "pinentry-program already configured"
elif grep -q "^pinentry-program " ~/.gnupg/gpg-agent.conf 2>/dev/null; then
    tmp_config="$(mktemp)"
    grep -v "^pinentry-program " ~/.gnupg/gpg-agent.conf > "$tmp_config"
    printf 'pinentry-program %s\n' "$PINENTRY_PATH" >> "$tmp_config"
    mv "$tmp_config" ~/.gnupg/gpg-agent.conf
    echo "Updated pinentry-program configuration"
else
    echo "pinentry-program $PINENTRY_PATH" >> ~/.gnupg/gpg-agent.conf
    echo "Added pinentry-program configuration"
fi

# Always restart the gpg-agent to apply any changes
gpgconf --kill gpg-agent
echo "GPG agent restarted"
