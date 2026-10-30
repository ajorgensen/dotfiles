#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$#" -ne 0 ]; then
  printf 'Usage: %s\n' "$0" >&2
  exit 1
fi

copy() {
  local source_path="$1"
  local target_path="$2"

  if [ ! -e "$source_path" ]; then
    printf 'Missing source: %s\n' "$source_path" >&2
    exit 1
  fi

  if [ -d "$source_path" ]; then
    mkdir -p "$target_path"
    # Merge contents without nesting directories or deleting local-only files.
    rsync -aL "$source_path/" "$target_path/"
    return
  fi

  mkdir -p "$(dirname "$target_path")"
  cp "$source_path" "$target_path"
}

merge_json() (
  local source_path="$1"
  local target_path="$2"
  local inputs=("$source_path")
  local temp_path

  if [ -f "$target_path" ]; then
    inputs+=("$target_path")
  fi

  mkdir -p "$(dirname "$target_path")"
  temp_path="$(mktemp "$target_path.XXXXXX")"
  trap 'rm -f "$temp_path"' EXIT

  # Later inputs win recursively; arrays are replaced, not combined.
  jq -e -s 'reduce .[] as $settings ({}; . * $settings)' "${inputs[@]}" >"$temp_path"
  mv "$temp_path" "$target_path"
)

copy "$SCRIPT_DIR/AGENTS.md" "$HOME/.codex/AGENTS.md"
copy "$SCRIPT_DIR/AGENTS.md" "$HOME/.claude/CLAUDE.md"
copy "$SCRIPT_DIR/AGENTS.md" "$HOME/.pi/agent/AGENTS.md"
copy "$SCRIPT_DIR/AGENTS.md" "$HOME/.config/maki/AGENTS.md"

for agent_dir in "$HOME/.codex" "$HOME/.claude" "$HOME/.pi/agent" "$HOME/.config/maki"; do
  copy "$SCRIPT_DIR/guidance" "$agent_dir/guidance"
  copy "$SCRIPT_DIR/skills" "$agent_dir/skills"
  # Private skills live outside this public repo.
  if [ -d "$HOME/.agents/skills" ]; then
    copy "$HOME/.agents/skills" "$agent_dir/skills"
  fi
done

# Local preferences and runtime state take precedence over shared defaults.
merge_json "$SCRIPT_DIR/pi/settings.json" "$HOME/.pi/agent/settings.json"
merge_json "$SCRIPT_DIR/pi/lsp.json" "$HOME/.pi/agent/lsp.json"
merge_json "$SCRIPT_DIR/pi/keybindings.json" "$HOME/.pi/agent/keybindings.json"
copy "$SCRIPT_DIR/pi/extensions" "$HOME/.pi/agent/extensions"
copy "$SCRIPT_DIR/pi/agents" "$HOME/.pi/agent/agents"
copy "$SCRIPT_DIR/pi/themes" "$HOME/.pi/agent/themes"
