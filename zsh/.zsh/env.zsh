[[ -n "${AJ_ZSH_ENV_LOADED:-}" ]] && return
export AJ_ZSH_ENV_LOADED=1

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export SHELL="${SHELL:-$(command -v zsh)}"
export EDITOR="${EDITOR:-nvim}"

if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

addToPath() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH="$PATH:$1"
    fi
}

addToPathFront() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH="$1:$PATH"
    fi
}

addToPathFront "$HOME/go/bin"
addToPathFront "$HOME/.local/bin"
addToPathFront "$HOME/.local/sbin"
addToPath "$HOME/sbin"
addToPath "$HOME/.cargo/bin"

export GOBIN="$HOME/go/bin"
