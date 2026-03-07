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
