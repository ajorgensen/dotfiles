#zmodload zsh/zprof

# Set custom prompt
setopt PROMPT_SUBST
autoload -U promptinit
promptinit
prompt grb

# Initialize completion only once per day
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

# Add pats
export PATH=$PATH:"$HOME/sbin"
export GOPATH="$HOME/go"
export PATH=$PATH:"$GOPATH/bin"

# FZF
export FZF_DEFAULT_COMMAND='ag --nocolor --ignore node_modules -g ""'

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
alias c="clear"
alias sysup='brew update && brew upgrade; brew cleanup'
alias tmpdir='pushd $(mktemp -d)'
alias cdf=find_and_cd
alias sz="source $HOME/.zshrc"
alias ec="$EDITOR $HOME/.my_zshrc"
function mkcd() { mkdir -p $1 && cd $1 }
function cdf() { cd *$1*/ } # stolen from @topfunky

# iOS
alias clear-derived-data="rm -rf /Users/ajorgensen/Library/Developer/Xcode/DerivedData/*"

# Ruby
alias be="bundle exec"
alias bspec="bundle exec rake spec"
alias r="bundle exec rails"
alias rc="bundle exec rails console"
alias rs="bundle exec rails server"
alias brs="be rspec"
alias dbreset="bundle exec rake db:drop db:create db:migrate db:seed db:test:prepare"

# Git
alias fbranch='git co $(git branch | fzf)'
alias g='git'

# Vim
alias v="vim"
alias vi="vim"

# FZF
# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# fda - including hidden directories
fda() {
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
}

# cf - fuzzy cd from anywhere
# ex: cf word1 word2 ... (even part of a file name)
# zsh autoload function
cf() {
  local file

  file="$(locate -Ai -0 $@ | grep -z -vE '~$' | fzf --read0 -0 -1)"

  if [[ -n $file ]]
  then
     if [[ -d $file ]]
     then
        cd -- $file
     else
        cd -- ${file:h}
     fi
  fi
}

# Grep processes and show headers.
function psgrep(){ ps -ef | sed -e '1p' -e "/$1/!d" }

# See what is listening on a given port: `whoport 80`
function whoport(){ lsof -i :$1 } # may need sudo

function git-current-branch-name(){
  echo $(git status | head -n 1 | awk '{ print $3 }')
}

function realpath() {
  echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
}

function abspath() {
  echo $(cd $(dirname $1); pwd)
}

function link() {
  ln -s $(realpath $1) $(realpath $2)
}

# Allows commit message without typing quotes (can't have quotes in the commit msg though).
function gcm {
  git commit -m "$*"
}

### Functions for setting and getting environment variables from the OSX keychain ###
# Use: keychain-environment-variable CHEF_PUSH_KEY
function keychain-environment-variable () {
    security find-generic-password -w -a ${USER} -D "environment variable" -s "${1}"
}

# Use: set-keychain-environment-variable CHEF_PUSH_KEY "secret"
function set-keychain-environment-variable () {
    [ -n "$1" ] || print "Missing environment variable name"
    [ -n "$2" ] || print "Missing environment variable value"
    ( [ -n "$1" ] && [ -n "$2" ] ) || return 1
    security add-generic-password -U -a ${USER} -D "environment variable" -s "${1}" -w "${2}"
}

# By @ieure; copied from https://gist.github.com/1474072
#
# It finds a file, looking up through parent directories until it finds one.
# Use it like this:
#
#   $ ls .tmux.conf
#   ls: .tmux.conf: No such file or directory
#
#   $ ls `up .tmux.conf`
#   /Users/grb/.tmux.conf
#
#   $ cat `up .tmux.conf`
#   set -g default-terminal "screen-256color"
#
function up()
{
    local DIR=$PWD
    local TARGET=$1
    while [ ! -e $DIR/$TARGET -a $DIR != "/" ]; do
        DIR=$(dirname $DIR)
    done
    test $DIR != "/" && echo $DIR/$TARGET
}

function em () {
  open -a /Applications/Emacs $*
}

# Platform Specific
if [[ $OSTYPE == darwin* ]]; then
  alias flush='dscacheutil -flushcache'
  # Apps
  alias browse="open -a /Applications/Google\ Chrome.app"
  alias slack="open -a /Applications/Slack.app"
  # Browser Shortcuts
  alias github="browse https://github.com"
  alias monorepo="browse https://github.com/Root-App/root-monorepo"
  alias sdk="browse https://github.com/Root-App/root-partner-sdk"
fi

source "$HOME/.local.zshrc"
#[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

#zprof
