export PATH="$HOME/bin:/usr/local/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
export SHELL_COMPLETION_DIR=$HOME/code/dev-box/dotfiles/shell_completion.d
export CDPATH="$HOME/code:$CDPATH"

source ~/code/dev-box/dotfiles/shell_exports

source ~/code/dev-box/dotfiles/aliases

USE_OH_MY_ZSH="true"
ZSH_THEME="bira"

# Case sensitive completion
CASE_SENSITIVE="true"

plugins=(asdf bundler docker gem git npm osx pip ruby tmux yarn)

eval "$(rbenv init -)"
eval "$(pyenv init -)"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

source ~/code/dev-box/dotfiles/shell_functions

if [ -e "$SHELL_COMPLETION_DIR" ]; then
  if [ `ls -1 $SHELL_COMPLETION_DIR/*.zsh 2>/dev/null | wc -l` -gt 0 ]; then
    for rcfile in $SHELL_COMPLETION_DIR/*.zsh; do
      . $rcfile
    done
  fi
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Please make all changes to this script above this line.
# The below will allow local overrides to strong opinions above.
if [ -e "$HOME/.my_zshrc" ]; then
  source "$HOME/.my_zshrc"
fi

if [[ "$USE_OH_MY_ZSH" == "true" ]]; then
  source $ZSH/oh-my-zsh.sh
fi

source "$HOME/code/dev-box/dotfiles/boxtipsrc"
