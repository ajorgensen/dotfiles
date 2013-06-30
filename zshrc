setopt PROMPT_SUBST
setopt AUTO_CD
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS

autoload -U promptinit
promptinit
prompt grb

autoload -U compinit
compinit

# Add paths that should have been there by default
export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/sbin:/usr/sbin:/bin:${PATH}
export PATH="$HOME/bin:$HOME/Applications:$PATH"
export PATH="$HOME/.rbenv/shims/:$HOME/.rbenv/bin:$PATH"

#eval "$(rbenv init -)"
[ -e ~/.rbenv/bin/rbenv ] && eval "$(rbenv init --no-rehash -)"
(rbenv rehash &) 2> /dev/null

# Colorize terminal
export TERM='xterm-256color'
alias ls='ls -G'
alias ll='ls -lG'
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
export GREP_OPTIONS="--color"

# Nicer history
export HISTSIZE=100000
export HISTFILE="$HOME/.history"
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
alias rbgrep="grep --include='*.rb' $*"
alias r=rails
alias rs="bundle exec rails server"
alias rc="bundle exec rails console"
alias ss="spin serve"
alias be="bundle exec"
alias gcm="git commit -m"
alias get="sudo apt-get install"

function mcd() { mkdir -p $1 && cd $1 }
function cdf() { cd *$1*/ } # stolen from @topfunky

function appleton() {
    if [ -z "$1" ]
    then
        cd ~/dev/backupify/appleton
    else
        cd ~/dev/backupify/appleton/$1*
    fi
}

function backupify() {
    cd ~/dev/backupify/backupify
}

# Aliases
alias r="bundle exec rails"
alias t="script/test $*"
alias f="script/features $*"
function mcd() { mkdir -p $1 && cd $1 }
function cdf() { cd *$1*/ } # stolen from @topfunky

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
alias homeconfig='git --git-dir=/home/andrew/.homeconfig.git/ --work-tree=/home/andrew'

function notify-command-complete(){
  wmctrl -i -r $WINDOWID -b add,demands_attention
}

add-zsh-hook precmd notify-command-complete

# If it exists, process ".sshagentrc"
SSHAGENTRC_FILE="$HOME/.sshagentrc";
if [ -f $SSHAGENTRC_FILE ];
then
	source $SSHAGENTRC_FILE;
fi

function chpwd() {
    emulate -L zsh
    ls -lrthG --color
}
