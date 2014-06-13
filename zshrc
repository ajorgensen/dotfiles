setopt PROMPT_SUBST
setopt AUTO_CD
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS INC_APPEND_HISTORY
setopt appendhistory

fpath=(~/.zsh/completion $fpath) 
fpath=(~/.zsh/functions $fpath) 

autoload -U compinit
compinit

# show completion menu when number of options is at least 2
zstyle ':completion:*' menu select=2
zstyle ":completion:*:descriptions" format "%B%d%b"

# Add paths that should have been there by default
export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/sbin:/usr/sbin:/bin:${PATH}
export PATH="$HOME/bin:$HOME/Applications:$PATH"
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.rbenv/shims/:$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
(rbenv rehash &) 2> /dev/null

# Colorize terminal
export TERM='xterm-256color'
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
export GREP_OPTIONS="--color"

# Nicer history
export HISTSIZE=100000
export HISTFILE="$HOME/.zsh_history"
export SAVEHIST=$HISTSIZE

# Hadoop
export PATH="$HOME/bin/hadoop-1.2.1/bin:$PATH"
export JAVA_HOME="/System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home"

export EDITOR=vim
bindkey -e

# Use qt4 because capybara-webkit needs it to compile
export QMAKE=/usr/bin/qmake-qt4

autoload -U history-search-end

zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
[[ -n "${key[Up]}" ]] && bindkey "${key[Up]}" history-beginning-search-backward-end
[[ -n "${key[Down]}" ]] && bindkey "${key[Down]}" history-beginning-search-forward-end
bindkey '^P' history-incremental-search-backward
bindkey '^N' history-incremental-search-forward

autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

export WORDCHARS='*?[]~&;!$%^<>'

export ACK_COLOR_MATCH='red'

# ACTUAL CUSTOMIZATION OH NOES!
gd() { git diff $* | view -; }
gdc() { gd --cached $*; }

function mcd() { mkdir -p $1 && cd $1 }
function cdf() { cd *$1*/ } # stolen from @topfunky

# Show contents of folder after cding into it
chpwd() {
  ls -lrthG
}

function chpwd() {
  emulate -L zsh
  ls -lrthG
}

export MARKPATH=$HOME/.marks
function jump { 
    cd -P $MARKPATH/$1 2>/dev/null || echo "No such mark: $1"
}

function mark { 
    mkdir -p $MARKPATH; ln -s $(pwd) $MARKPATH/$1
}

function unmark { 
    rm -i $MARKPATH/$1 
}

function marks {
    ls -l $MARKPATH | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
}

# Allows commit message without typing quotes (can't have quotes in the commit msg though).
function gc {
  git commit -m "$*"
}

## case-insensitive (all), partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Sourcing of other files
source $HOME/.zsh/aliases
source $HOME/.zsh/functions/zgitinit
source $HOME/.zsh/functions/zsh_prompt
if [ -e $HOME/.secret_zshrc ]; then
  source $HOME/.secret_zshrc
fi
