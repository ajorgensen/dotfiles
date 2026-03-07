bindkey -e
bindkey -s ^f "tmux-sessionizer\n"

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

fzf-git-branch-widget() {
    local selected_branch
    selected_branch=$(
        git for-each-ref --sort=-committerdate refs/heads/ \
            --format='%(refname:short)' |
        fzf --height=20% --reverse --info=inline --preview 'git log --oneline -n 10 {}' < /dev/tty
    )

    if [[ -n "$selected_branch" ]]; then
        LBUFFER+="$selected_branch"
    fi

    zle reset-prompt
    zle -R
}

zle -N fzf-git-branch-widget
bindkey ^x "fzf-git-branch-widget"
