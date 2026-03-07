export XDG_CONFIG_HOME="$HOME/.config"
export SHELL="$(which zsh)"
export EDITOR="nvim"

eval "$(/opt/homebrew/bin/brew shellenv)"

addToPath() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH=$PATH:$1
    fi
}

addToPathFront() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH=$1:$PATH
    fi
}

addToPathFront $HOME/go/bin
addToPathFront $HOME/.local/bin
addToPathFront $HOME/.local/sbin
addToPath $HOME/sbin
addToPath $HOME/.cargo/bin

export GOBIN="$HOME/go/bin"

