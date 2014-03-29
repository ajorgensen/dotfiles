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
set PATH $PATH "$HOME/bin"

# rbenv stuff
set PATH "$HOME/.rbenv/bin" $PATH
set PATH "$HOME/.rbenv/shims" $PATH
rbenv rehash >/dev/null ^&1

# Android SDK stuff
set ANDROID_SDK ~/dev/android-sdk/sdk
set ANDROID_NDK ~/dev/android-ndk
set PATH "$ANDROID_SDK/tools" $PATH
set PATH "$ANDROID_SDK/platform-tools" $PATH 
set GRADLE_OPTS "-Xmx1024m -Xms256m -XX:MaxPermSize=512m"

# Hadoop
set PATH "$HOME/bin/hadoop-1.2.1/bin" $PATH
set -x JAVA_HOME "/System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home"

# Storm
set PATH "/crashlytics/storm-0.9.0-rc2/bin" $PATH

set PATH "/Applications/eclipse" $PATH
set PATH '/usr/local/sbin' $PATH
set PATH '$HOME/bin' $PATH

# Cassandra
set PATH '$HOME/bin/apache-cassandra-1.1.12/bin' $PATH

#GPG
set -x KEYID "AC6E2D2F"

# ALIASES
alias r=rails
alias rs="bundle exec rails server"
alias rc="bundle exec rails console"
alias ss="spin serve"
alias be="bundle exec"
alias amend="git commit --amend"
alias gcm="git commit -m"
alias gs="git status -sb"
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
alias autotest="lein midje :autotest src/ test/"
alias clean-merged="git checkout master; git branch --merged | grep -v '\*' | xargs -n 1 git branch -d"
alias cgrep="grep --color=always"

set -x MARKPATH $HOME/.marks

function jump
  cd $MARKPATH/$argv 2>/dev/null; or echo "No such mark: $argv"
end

function mark
    mkdir -p $MARKPATH; ln -s (pwd) $MARKPATH/$argv
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
