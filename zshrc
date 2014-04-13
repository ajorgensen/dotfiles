setopt PROMPT_SUBST
setopt AUTO_CD
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS

autoload -U compinit
compinit

# Add paths that should have been there by default
export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/sbin:/usr/sbin:/bin:${PATH}
export PATH="$HOME/bin:$HOME/Applications:$PATH"
export PATH="$HOME/.rbenv/shims/:$HOME/.rbenv/bin:$PATH"

#eval "$(rbenv init -)"
export PATH="$HOME/.rbenv/bin:$PATH"
[ -e ~/.rbenv/bin/rbenv ] && eval "$(rbenv init --no-rehash -)"
(rbenv rehash &) 2> /dev/null

# Colorize terminal
export TERM='xterm-256color'
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
export GREP_OPTIONS="--color"

# Nicer history
export HISTSIZE=100000
export HISTFILE="$HOME/.zsh_history"
export SAVEHIST=$HISTSIZE

export EDITOR=vim

# Use qt4 because capybara-webkit needs it to compile
export QMAKE=/usr/bin/qmake-qt4

# Ruby performance stuff
export RUBY_GC_MALLOC_LIMIT=60000000
export RUBY_FREE_MIN=200000

autoload -U history-search-end

zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
[[ -n "${key[Up]}" ]] && bindkey "${key[Up]}" history-beginning-search-backward-end
[[ -n "${key[Down]}" ]] && bindkey "${key[Down]}" history-beginning-search-forward-end

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

if [ -e /usr/share/terminfo/x/xterm-256color ]; then
        export TERM='xterm-256color'
else
        export TERM='xterm-color'
fi

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

# Sourcing of other files
source $HOME/.zsh/aliases
source $HOME/.zsh/functions/zgitinit
source $HOME/.zsh/functions/zsh_prompt
