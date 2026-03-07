# NVM (lazy-loaded for fast startup)
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    # Add node to PATH immediately (without loading nvm) so node/npm work
    [ -s "$NVM_DIR/alias/default" ] && PATH="$NVM_DIR/versions/node/$(cat "$NVM_DIR/alias/default")/bin:$PATH"
    # Lazy-load nvm itself on first use
    _lazy_load_nvm() {
        unset -f nvm node npm npx
        \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    }
    nvm() { _lazy_load_nvm; nvm "$@" }
    node() { _lazy_load_nvm; node "$@" }
    npm() { _lazy_load_nvm; npm "$@" }
    npx() { _lazy_load_nvm; npx "$@" }
fi

# GPG agent
if ! pgrep -x -u "${USER}" gpg-agent >/dev/null 2>&1; then
    gpg-connect-agent /bye >/dev/null 2>&1
fi
