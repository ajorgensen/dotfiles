# Keychain helpers
function keychain-environment-variable() {
    security find-generic-password -w -a ${USER} -D "environment variable" -s "${1}"
}

function set-keychain-environment-variable() {
    [ -n "$1" ] || print "Missing environment variable name"
    read -s "?Enter Value for ${1}: " secret
    ( [ -n "$1" ] && [ -n "$secret" ] ) || return 1
    security add-generic-password -U -a ${USER} -D "environment variable" -s "${1}" -w "${secret}"
}

# Utilities
function jwt-decode() {
    jq -R 'split(".") |.[0:2] | map(gsub("-"; "+") | gsub("_"; "/") | gsub("%3D"; "=") | @base64d) | map(fromjson)'
}

function docker_rm_stopped() {
    docker rm $(docker ps -a -q)
}

function gencode() {
    base64 < /dev/urandom | tr -dc 'A-Z0-9' | head -c "$1"
}

function notifyMe() {
    osascript -e "display notification \"todo\" with title \"$1\" sound name \"Submarine\""
}

function np() {
    local file exit_status tmpdir
    tmpdir="${TMPDIR:-/tmp}"
    file="$(mktemp "${tmpdir%/}/np.XXXXXX")" || return

    nvim "$file" < /dev/tty > /dev/tty 2> /dev/tty
    exit_status=$?

    if (( exit_status == 0 )); then
        cat "$file"
    fi

    rm -f "$file"
    return $exit_status
}

function gwcd() {
    local query="${1:-}"
    local worktrees selected worktree_path label created_at
    local -a entries matches

    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        print -u2 "gwcd: not in a git repository"
        return 1
    fi

    worktrees="$(git worktree list --porcelain | awk -v q="$query" '
        function emit() {
            if (path == "" || prunable) return
            label = branch == "" ? "(unknown)" : branch
            line = label "\t" path
            if (q == "" || index(label, q) || index(path, q)) print line
        }

        /^worktree / {
            emit()
            path = substr($0, 10)
            branch = ""
            prunable = 0
            next
        }

        /^branch / {
            branch = substr($0, 8)
            sub(/^refs\/heads\//, "", branch)
            next
        }

        /^detached$/ { branch = "(detached)"; next }
        /^bare$/ { branch = "(bare)"; next }
        /^prunable/ { prunable = 1; next }
        /^$/ { emit(); path = ""; branch = ""; prunable = 0; next }
        END { emit() }
    ')"

    if [[ -z "$worktrees" ]]; then
        if [[ -n "$query" ]]; then
            print -u2 "gwcd: no worktree matches '$query'"
        else
            print -u2 "gwcd: no worktrees found"
        fi
        return 1
    fi

    entries=()
    while IFS=$'\t' read -r label worktree_path; do
        [[ -n "$worktree_path" ]] || continue
        created_at="$(stat -f %B "$worktree_path" 2>/dev/null)"
        [[ -n "$created_at" && "$created_at" != "-1" ]] || created_at="$(stat -f %m "$worktree_path" 2>/dev/null)"
        entries+=("${created_at:-0}"$'\t'"${label}"$'\t'"${worktree_path}")
    done <<< "$worktrees"

    matches=("${(@f)$(printf '%s\n' "${entries[@]}" | sort -rn -k1,1 | cut -f2-)}")

    if (( ${#matches[@]} == 1 )); then
        selected="${matches[1]}"
    else
        if ! command -v fzf >/dev/null 2>&1; then
            print -u2 "gwcd: multiple worktrees matched, but fzf is not installed"
            printf '  %s\n' "${matches[@]}" >&2
            return 1
        fi

        selected="$(printf '%s\n' "${matches[@]}" | fzf --no-sort --height=40% --reverse --prompt='worktree> ')" || return
    fi

    worktree_path="${selected##*$'\t'}"
    if [[ ! -d "$worktree_path" ]]; then
        print -u2 "gwcd: worktree path does not exist: $worktree_path"
        return 1
    fi

    cd "$worktree_path"
}

function gwls() {
    local worktrees line worktree_path branch commit timestamp date
    local -a entries

    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        print -u2 "gwls: not in a git repository"
        return 1
    fi

    worktrees="$(git worktree list --porcelain | awk '
        function emit() {
            if (path == "" || prunable) return
            label = branch == "" ? "(detached)" : branch
            print path "\t" label "\t" commit
        }

        /^worktree / {
            emit()
            path = substr($0, 10)
            branch = ""
            commit = ""
            prunable = 0
            next
        }

        /^HEAD / { commit = substr($0, 6); next }
        /^branch / {
            branch = substr($0, 8)
            sub(/^refs\/heads\//, "", branch)
            next
        }

        /^bare$/ { branch = "(bare)"; next }
        /^prunable/ { prunable = 1; next }
        /^$/ { emit(); path = ""; branch = ""; commit = ""; prunable = 0; next }
        END { emit() }
    ')"

    if [[ -z "$worktrees" ]]; then
        print -u2 "gwls: no worktrees found"
        return 1
    fi

    entries=()
    while IFS=$'\t' read -r worktree_path branch commit; do
        [[ -n "$worktree_path" && -n "$commit" ]] || continue
        timestamp="$(git -C "$worktree_path" log -1 --format=%ct "$commit" 2>/dev/null)" || continue
        date="$(git -C "$worktree_path" log -1 --format=%ci "$commit" 2>/dev/null)" || continue
        entries+=("${timestamp}"$'\t'"${date}"$'\t'"${branch}"$'\t'"${worktree_path}")
    done <<< "$worktrees"

    if (( ${#entries[@]} == 0 )); then
        print -u2 "gwls: no worktrees found"
        return 1
    fi

    printf '%s\n' "${entries[@]}" | sort -rn | cut -f2-
}

function gwmux() {
    local worktrees selected worktree_path session_name target_session
    local name label created_at
    local -a entries

    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        print -u2 "gwmux: not in a git repository"
        return 1
    fi

    if ! command -v tmux >/dev/null 2>&1; then
        print -u2 "gwmux: tmux is not installed"
        return 1
    fi

    if ! command -v fzf >/dev/null 2>&1; then
        print -u2 "gwmux: fzf is not installed"
        return 1
    fi

    worktrees="$(git worktree list --porcelain | awk '
        function emit() {
            if (path == "" || prunable) return
            name = path
            sub(/^.*\//, "", name)
            label = branch == "" ? "(detached)" : branch
            print name "\t" label "\t" path
        }

        /^worktree / {
            emit()
            path = substr($0, 10)
            branch = ""
            prunable = 0
            next
        }

        /^branch / {
            branch = substr($0, 8)
            sub(/^refs\/heads\//, "", branch)
            next
        }

        /^detached$/ { branch = "(detached)"; next }
        /^bare$/ { branch = "(bare)"; next }
        /^prunable/ { prunable = 1; next }
        /^$/ { emit(); path = ""; branch = ""; prunable = 0; next }
        END { emit() }
    ')"

    if [[ -z "$worktrees" ]]; then
        print -u2 "gwmux: no worktrees found"
        return 1
    fi

    entries=()
    while IFS=$'\t' read -r name label worktree_path; do
        [[ -n "$worktree_path" ]] || continue
        created_at="$(stat -f %B "$worktree_path" 2>/dev/null)"
        [[ -n "$created_at" && "$created_at" != "-1" ]] || created_at="$(stat -f %m "$worktree_path" 2>/dev/null)"
        entries+=("${created_at:-0}"$'\t'"${name}"$'\t'"${label}"$'\t'"${worktree_path}")
    done <<< "$worktrees"

    selected="$(printf '%s\n' "${entries[@]}" | sort -rn -k1,1 | cut -f2- | fzf --no-sort --height=40% --reverse --prompt='worktree tmux> ' --exit-0)" || return
    [[ -n "$selected" ]] || return

    worktree_path="${selected##*$'\t'}"
    if [[ ! -d "$worktree_path" ]]; then
        print -u2 "gwmux: worktree path does not exist: $worktree_path"
        return 1
    fi

    session_name="${worktree_path:t}"
    [[ -n "$session_name" ]] || session_name="main"
    target_session="=${session_name}"

    if [[ -n "$TMUX" ]]; then
        if ! tmux has-session -t "$target_session" 2>/dev/null; then
            TMUX= tmux new-session -ds "$session_name" -c "$worktree_path"
        fi

        tmux switch-client -t "$target_session"
    else
        if tmux has-session -t "$target_session" 2>/dev/null; then
            tmux attach-session -t "$target_session"
        else
            tmux new-session -s "$session_name" -c "$worktree_path"
        fi
    fi
}

# Tmux helpers
function tmux-session() {
    local session

    if ! command -v tmux >/dev/null 2>&1; then
        print -u2 "tmux-session: tmux is not installed"
        return 1
    fi

    if ! command -v fzf >/dev/null 2>&1; then
        print -u2 "tmux-session: fzf is not installed"
        return 1
    fi

    session="$(tmux list-sessions -F '#{session_created}'$'\t''#{session_name}' 2>/dev/null \
        | sort -rn -k1,1 \
        | cut -f2- \
        | fzf --no-sort --prompt='tmux session> ' --height=40% --reverse --exit-0)" || return
    [[ -n "$session" ]] || return

    if [[ -n "$TMUX" ]]; then
        tmux switch-client -t "$session"
    else
        tmux attach-session -t "$session"
    fi
}

function tcd() {
    local session_name="${PWD:t}"
    session_name="${session_name//[^[:alnum:]_-]/_}"
    [[ -n "$session_name" ]] || session_name="main"

    if command -v tm >/dev/null 2>&1; then
        tm "$session_name"
        return
    fi

    if [[ -z "$TMUX" ]]; then
        tmux new-session -As "$session_name"
    else
        if ! tmux has-session -t "$session_name" 2>/dev/null; then
            TMUX= tmux new-session -ds "$session_name"
        fi
        tmux switch-client -t "$session_name"
    fi
}

function git-prune-remote() {
  git fetch --prune
  git branch -r \
    | grep -v HEAD \
    | grep -v 'origin/main\|origin/master' \
    | sed 's|origin/||' \
    | fzf -m --header="TAB to select branches to delete on origin" \
    | xargs -r -n1 git push origin --delete
}
