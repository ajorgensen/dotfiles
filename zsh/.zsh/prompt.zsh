autoload -Uz vcs_info
precmd() { vcs_info }

local vc_branch_name="%B%F{yellow}%i %b%f%%b"
local vc_git_staged_status=" %F{green}+%f"
local vc_unstaged_status=" ${char_next}%F{blue}M%f"

zstyle ":vcs_info:git:*" formats ' (%b%u%c)'
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr $vc_git_staged_status
zstyle ':vcs_info:git:*' unstagedstr $vc_unstaged_status

setopt prompt_subst
autoload -U colors && colors
prompt='%F{green}%~%F{yellow}${vcs_info_msg_0_} %F{reset}> '
