alias sysup='brew -v update && brew -v upgrade; brew -v cleanup'
alias sz="source $HOME/.zshrc"

alias ls='ls -lG'
alias pip=pip3
alias python=python3
alias c="clear"
alias pmake="make -j $(nproc)"
alias g="git"

alias go-unused='staticcheck -checks U1000'

alias tnew='tmux new-session -A -s'

alias gswitch="git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)' | fzf --height=20% --reverse --info=inline | xargs -I {} git switch {}"
alias gbranch="git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)' | fzf --height=20% --reverse --info=inline"
