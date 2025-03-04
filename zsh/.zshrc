#zmodload zsh/zprof

autoload -U compinit; compinit
source $HOME/.zsh/prompt

bindkey '^R' history-incremental-search-backward

export HISTSIZE=100000000
export SAVEHIST=$HISTSIZE
export HISTFILE=$HOME/.local/zsh_history

include () {
    [[ -f "$1" ]] && source $1
}

include $HOME/.zsh/aliases
include $HOME/.zsh/funcs
include $HOME/.zsh_profile

#zprof
