alias c="clear"
alias vim='nvim'
alias ls='ls --color=auto'

export EDITOR="nvim"
export SHELL="zsh"

export GOPATH="$HOME/.go"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:/usr/local/sbin"

docker_rm_stopped() {
  docker rm $(docker ps -a -q)
}

if which jenv > /dev/null; then eval "$(jenv init -)"; fi

if ! type open > /dev/null ; then
  alias open=xdg-open
fi

# Start the gpg-agent if not already running
if ! pgrep -x -u "${USER}" gpg-agent >/dev/null 2>&1; then
  gpg-connect-agent /bye >/dev/null 2>&1
fi

alias gpg-unlock="gpg-connect-agent updatestartuptty /bye"