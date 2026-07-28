# General
alias c="clear"
alias g="git"
alias ls='ls -lG'
alias pip=pip3
alias python=python3
alias vim="nvim"
alias e="nvim"
alias sz="source $HOME/.zshrc"
alias sysup='brew -v update && brew -v upgrade; brew -v cleanup'

# AI agents
alias dcodex='codex --dangerously-bypass-approvals-and-sandbox'
alias dclaude='claude --dangerously-skip-permissions'

# Tmux
alias tnew='tmux new-session -A -s'
tpick() {
  local session
  session=$(tmux list-sessions -F '#S' 2>/dev/null | fzf --height=20% --reverse --info=inline) || return
  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$session"
  else
    tmux attach -t "$session"
  fi
}
tkill() {
  tmux list-sessions -F '#S' 2>/dev/null |
    fzf --multi --height=20% --reverse --info=inline |
    while read -r session; do tmux kill-session -t "$session"; done
}

# Git
alias gswitch="git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)' | fzf --height=20% --reverse --info=inline | xargs -I {} git switch {}"
alias gbranch="git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)' | fzf --height=20% --reverse --info=inline"
alias copy-branch-name="git current-branch | pbcopy"

# GPG
alias gpg-unlock="gpg-connect-agent updatestartuptty /bye"

# Wezterm
alias wztitle="wezterm cli set-tab-title"

# Go
alias go-unused='staticcheck -checks U1000'
alias go-check="go-build && go-test && go-lint"

# Check/lint shortcuts
alias check-java="make format test"
alias check-go="make lint test"
alias check-js="make lint test"

# JS lint
alias js-lint-changed='git diff --name-only --cached --diff-filter=ACMRTUXB | grep -E "\.(js|jsx|ts|tsx)\\$" | xargs pnpm exec prettier --write'

# Sync
alias sync-all='find . -name ".git" -not -path "*/.build/*" -type d -ls -exec git --git-dir {} remote prune origin \; -exec git --git-dir {} gc \; -prune -execdir git pull \;'
