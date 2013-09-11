# OSX tweaks
if set -q Apple_PubSub_Socket_Render
  # bind \cleft and \cright
  bind \e\[5D prevd-or-backward-word
  bind \e\[5C nextd-or-forward-word
end

# Fish git prompt
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch red
set __fish_git_prompt_showuntrackedfiles 'true' 

# Status Chars
#set __fish_git_prompt_char_dirtystate '*'
#set __fish_git_prompt_char_stagedstate '→'
#set __fish_git_prompt_char_stashstate '↩'
#set __fish_git_prompt_char_upstream_ahead '↑'
#set __fish_git_prompt_char_upstream_behind '↓'
#set __fish_git_prompt_char_untrackedfiles '!'

set PATH "/usr/local/bin" $PATH
set PATH $PATH "/usr/bin"

# rbenv stuff
set PATH "$HOME/.rbenv/bin" $PATH
set PATH "$HOME/.rbenv/shims" $PATH
rbenv rehash >/dev/null ^&1

# ALIASES
alias r=rails
alias rs="bundle exec rails server"
alias rc="bundle exec rails console"
alias ss="spin serve"
alias be="bundle exec"
alias amend="git commit --amend"
alias gcm="git commit -m"
alias gs="git status"
alias gaa="git add --all"
alias gap="git add --patch"
alias gp="git put"
alias glog="git log --color"
alias gpull="git pull"
alias gco="git checkout"
alias get="sudo apt-get install"
alias ls="ls -lrthG"
alias shnow="sudo shutdown -h now"
alias gdiff="git diff --color"
alias pag="ps aux | grep"
alias j="jump"
alias m="mark"
alias um="unmark"

set -x MARKPATH $HOME/.marks

function jump
  cd $MARKPATH/$argv 2>/dev/null; or echo "No such mark: $argv"
end

function mark
    mkdir -p $MARKPATH; ln -s (pwd) $MARKPATH/$argv
end

function grep
  command grep --color=always $argv
end

function unmark
    rm -i $MARKPATH/$argv 
end

function marks
  ls -l $MARKPATH | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\-/g'
end

function cdls
  cd $argv ;and ls
end

function cd
  builtin cd $argv; and ls
end

# Allows commit message without typing quotes (can't have quotes in the commit msg though).
function gc 
  git commit -m "$argv"
end
