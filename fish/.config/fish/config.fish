set -gx XDG_CONFIG_HOME "$HOME/.config"

set -gx SHELL (which fish)
set -gx EDITOR "nvim"
alias vim="nvim"
alias e="nvim"

fish_vi_key_bindings
# set fish_vi_mode_display_mode 0

fish_add_path "$HOME/.local/sbin"
fish_add_path "$HOME/.local/bin"

function include
    test -f $argv[1]; and source $argv[1]
end

include "$HOME/.config/fish/aliases.fish"
include "$HOME/.config/fish/functions.fish"
include "$HOME/.local.fish"
