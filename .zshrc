#zmodload zsh/zprof

fpath+=$HOME/.zsh/plugins/pure
autoload -U promptinit; promptinit
prompt pure

# Initialize completion
autoload -U compinit
compinit -D

# miniplug
source "$HOME/.zsh/plugins/miniplug.zsh"

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#8a8a8a"

miniplug plugin 'davidparsson/zsh-nvm-lazy'
miniplug plugin 'zsh-users/zsh-autosuggestions'
miniplug plugin 'zsh-users/zsh-completions'
miniplug plugin 'zsh-users/zsh-syntax-highlighting'
miniplug plugin 'unixorn/fzf-zsh-plugin'

miniplug load

# Add paths
export PATH=$PATH:"$HOME/sbin":$HOME/bin
export GOPATH="$HOME/go"
export PATH=$PATH:"$GOPATH/bin"

# FZF
export FZF_DEFAULT_COMMAND='ag --nocolor --ignore node_modules -g ""'

# Ruby
eval "$(rbenv init - zsh)"

# Colorize terminalA
alias ls='ls -G'
alias ll='ls -lG'
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"

# Nicer History
export HISTSIZE=100000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE

# Editor
export EDITOR="vim"
set -o emacs

# Use C-x C-e to edit the current command line
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# By default, zsh considers many characters part of a word (e.g., _ and -).
# Narrow that down to allow easier skipping through words via M-f and M-b.
export WORDCHARS='*?[]~&;!$%^<>'

# Highlight search results in ack.
export ACK_COLOR_MATCH='red'

# Aliases
source $HOME/.zsh/aliases

# Funcs
source $HOME/.zsh/funcs

include () {
    [[ -f "$1" ]] && source "$1"
}
include "$HOME/.local.zshrc"

#zprof