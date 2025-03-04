#!/usr/bin/env bash

# Check if the gpg-agent.conf file exists
if [ ! -d ~/.gnupg ]; then
    mkdir -p ~/.gnupg
    chmod 700 ~/.gnupg
fi

# Check if pinentry-program is already configured
if ! grep -q "pinentry-program /opt/homebrew/bin/pinentry-mac" ~/.gnupg/gpg-agent.conf 2>/dev/null; then
    echo "pinentry-program /opt/homebrew/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
    echo "Added pinentry-program configuration"
else
    echo "pinentry-program already configured"
fi

# Always restart the gpg-agent to apply any changes
gpgconf --kill gpg-agent
echo "GPG agent restarted"
