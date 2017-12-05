function fish_prompt --description 'Write out the prompt'

  set -l last_status $status

  set_color $fish_color_cwd
  echo -n (prompt_pwd)
  set_color normal

  __informative_git_prompt

  if not test $last_status -eq 0
    set_color $fish_color_error
  end

  echo -n ' $ '
end

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
alias fbranch "git co (git branch | fzf)"

function gc
  git commit -m "$argv"
end

set -g GOPATH $HOME/src/golang
set -g CDPATH $HOME $HOME/src $GOPATH
