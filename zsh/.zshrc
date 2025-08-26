#zmodload zsh/zprof

autoload -U compinit; compinit
source $HOME/.zsh/prompt

export HISTSIZE=100000000
export SAVEHIST=$HISTSIZE
export HISTFILE=$HOME/.local/zsh_history

setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS

include () {
    [[ -f "$1" ]] && source $1
}

include $HOME/.zsh/aliases
include $HOME/.zsh/funcs
include $HOME/.zsh_profile

#zprof
