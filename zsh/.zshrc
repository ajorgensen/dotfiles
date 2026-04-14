if [[ -n "$ZSH_DEBUGRC" ]]; then
    zmodload zsh/zprof
fi

source "$HOME/.zsh/env.zsh"
source "$HOME/.zsh/options.zsh"
source "$HOME/.zsh/tools.zsh"
source "$HOME/.zsh/completion.zsh"
source "$HOME/.zsh/prompt.zsh"
source "$HOME/.zsh/keybindings.zsh"
source "$HOME/.zsh/aliases.zsh"
source "$HOME/.zsh/functions.zsh"

# Machine-specific overrides
[[ -f "$HOME/.local.zshrc" ]] && source "$HOME/.local.zshrc"

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

if [[ -n "$ZSH_DEBUGRC" ]]; then
    zprof
fi
