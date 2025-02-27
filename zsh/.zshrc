#zmodload zsh/zprof

source $HOME/.zsh/prompt

include () {
    [[ -f "$1" ]] && source $1
}

include $HOME/.zsh/aliases
include $HOME/.zsh/funcs

#zprof
