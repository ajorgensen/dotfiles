# Function to get environment variables from the OSX keychain
# Usage: keychain-environment-variable SECRET_ENV_VAR
function keychain-environment-variable --description "Get environment variable from OSX keychain"
    security find-generic-password -w -a $USER -D "environment variable" -s "$argv[1]"
end

# Function to set environment variables in the OSX keychain
# Usage: set-keychain-environment-variable SECRET_ENV_VAR
function set-keychain-environment-variable --description "Set environment variable in OSX keychain"
    if test -z "$argv[1]"
        echo "Missing environment variable name"
        return 1
    end

    # Read secret input with Fish's read command
    read -s -P "Enter Value for $argv[1]: " secret
    
    if test -z "$argv[1]" -o -z "$secret"
        return 1
    end
    
    security add-generic-password -U -a $USER -D "environment variable" -s "$argv[1]" -w "$secret"
end

# Function to decode JWT tokens
function jwt-decode --description "Decode JWT tokens"
    jq -R 'split(".") |.[0:2] | map(gsub("-"; "+") | gsub("_"; "/") | gsub("%3D"; "=") | @base64d) | map(fromjson)'
end

# Function to remove all stopped Docker containers
function docker_rm_stopped --description "Remove all stopped Docker containers"
    docker rm (docker ps -a -q)
end
