# Save this to ~/.config/fish/functions/fish_prompt.fish

function fish_prompt --description 'Write out the prompt'
    set -l last_status $status

    # Current directory
    set_color $fish_color_cwd
    echo -n (prompt_pwd)
    set_color normal

    # Git status
    set -l git_info
    if command -sq git
        set -l git_branch (git branch 2>/dev/null | sed -n '/\* /s///p')
        if test -n "$git_branch"
            set -l git_status (git status --porcelain 2>/dev/null)
            
            set_color yellow
            echo -n " ($git_branch"
            
            # Check for modified files
            if test -n "$git_status"
                set_color red
                echo -n " ●"
            end
            
            # Check for staged files
            if git diff --cached --quiet 2>/dev/null
                # No staged files
            else
                set_color green
                echo -n " +"
            end
            
            # Check for untracked files
            if test -n "$(git ls-files --others --exclude-standard 2>/dev/null)"
                set_color cyan
                echo -n " ?"
            end
            
            set_color yellow
            echo -n ")"
        end
    end
    set_color normal

    # Error status
    if test $last_status -ne 0
        set_color $fish_color_error
        echo -n " [$last_status]"
        set_color normal
    end

    # Terminating prompt character
    echo -n ' > '
end
