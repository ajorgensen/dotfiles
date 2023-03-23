alias sz "source $HOME/.config/fish/config.fish"
alias gs "git staus"
alias be "bundle exec"
alias amend "git commit --amend"
alias gcm "git commit -v"
alias gs "git status"
alias gaa "git add --all"
alias gap "git add --patch"
alias gp "git put"
alias gpf "git put -f"
alias glog "git log --color"
alias gpull "git pull"
alias gco "git checkout"
alias ls "ls -lrthG"
alias shnow "sudo shutdown -h now"
alias gdiff "git diff --color"
alias pag "ps aux | grep"
alias retag "ctags -R --exclude=.svn --exclude=.git --exclude=log --exclude=tmp *"
alias grim "git rebase -i origin/master"
alias g "git"
alias gpop "git stash pop"
alias gstash "git stash"
alias gcob "git co -b"
alias v "vim"
alias c "clear"
alias vi "vim"
alias fixup "gaa; gc f; grim"
alias restart "shutdown -r now"
alias sysup "brew update && brew upgrade; brew cleanup"
alias rs "bundle exec rails server"

function fbranch -d "Fuzzy-find and checkout a branch"
  git branch --all | grep -v HEAD | string trim | fzf | read -l result; and git checkout "$result"
end

function fcommit -d "Fuzzy-find and checkout a commit"
  git log --pretty=oneline --abbrev-commit --reverse | fzf --tac +s -e | awk '{print $1;}' | read -l result; and git checkout "$result"
end

function gc
  git commit -m "$argv"
end

set -g GOPATH $HOME/src/golang $HOME/go
set -g CDPATH . $HOME $HOME/code $GOPATH
set -gx PATH $HOME/bin $HOME/sbin $HOME/go/bin $HOME/.cargo/bin $PATH

set fish_greeting

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ajorgensen/google-cloud-sdk/path.fish.inc' ]; . '/Users/ajorgensen/google-cloud-sdk/path.fish.inc'; end

# FZF
set -gx FZF_DEFAULT_COMMAND 'ag --nocolor --ignore node_modules -g ""'

if test -e ~/.local.fish
  source ~/.local.fish
end
set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
