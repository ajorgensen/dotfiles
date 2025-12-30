if [[ -n "$ZSH_DEBUGRC" ]]; then
    zmodload zsh/zprof
fi

fpath=("$HOME/.zsh/completion" $fpath)
autoload -U compinit; compinit
source $HOME/.zsh/prompt

export HISTSIZE=100000000
export SAVEHIST=$HISTSIZE
export HISTFILE=$HOME/.local/zsh_history

setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS

[[ -f "$HOME/.zsh/aliases" ]] && source "$HOME/.zsh/aliases"
[[ -f "$HOME/.zsh/funcs" ]] && source "$HOME/.zsh/funcs"
[[ -f "$HOME/.zsh_profile" ]] && source "$HOME/.zsh_profile"

if [[ -n "$ZSH_DEBUGRC" ]]; then
    zprof
fi
