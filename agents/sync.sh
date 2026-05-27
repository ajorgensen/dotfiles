#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)"

AGENTS_FILE="$SCRIPT_DIR/AGENTS.md"
SKILLS_DIR="$SCRIPT_DIR/skills"
OPENCODE_DIR="$SCRIPT_DIR/opencode"
PI_DIR="$SCRIPT_DIR/pi"

require_file() {
  local path="$1"

  if [ ! -f "$path" ]; then
    echo "Missing file: $path" >&2
    exit 1
  fi
}

require_dir() {
  local path="$1"

  if [ ! -d "$path" ]; then
    echo "Missing directory: $path" >&2
    exit 1
  fi
}

validate_sources() {
  require_file "$AGENTS_FILE"
  require_dir "$SKILLS_DIR"

  require_file "$OPENCODE_DIR/opencode.json"
  require_dir "$OPENCODE_DIR/plugin"

  require_file "$PI_DIR/settings.json"
  require_dir "$PI_DIR/agents"
  require_dir "$PI_DIR/extensions"
  require_dir "$PI_DIR/prompts"
  require_dir "$PI_DIR/themes"
}

materialize_dir() {
  local target_dir="$1"
  local source_dir=""

  if [ -L "$target_dir" ]; then
    if [ -d "$target_dir" ]; then
      source_dir="$(
        cd "$target_dir" && pwd -P
      )"
    fi

    rm "$target_dir"
    mkdir -p "$target_dir"

    if [ -n "$source_dir" ]; then
      rsync -a "$source_dir/" "$target_dir/"
    fi
  else
    mkdir -p "$target_dir"
  fi
}

sync_file() {
  local source_file="$1"
  local target_file="$2"
  local target_dir

  target_dir="$(dirname "$target_file")"
  materialize_dir "$target_dir"
  rsync -a "$source_file" "$target_file"
}

sync_optional_file() {
  local source_file="$1"
  local target_file="$2"

  if [ -f "$source_file" ]; then
    sync_file "$source_file" "$target_file"
  fi
}

sync_dir() {
  local source_dir="$1"
  local target_dir="$2"

  materialize_dir "$target_dir"
  # Do not use --delete; agent homes also contain tool-owned runtime files.
  rsync -a "$source_dir/" "$target_dir/"
}

sync_instructions() {
  local target_dir="$1"
  local target_file="$2"

  sync_file "$AGENTS_FILE" "$target_dir/$target_file"
}

sync_skills() {
  local target_dir="$1"

  sync_dir "$SKILLS_DIR" "$target_dir/skills"
}

sync_codex() {
  sync_instructions "$HOME/.codex" "AGENTS.md"
  sync_skills "$HOME/.codex"
}

sync_claude() {
  sync_instructions "$HOME/.claude" "CLAUDE.md"
  sync_skills "$HOME/.claude"
}

sync_opencode() {
  # Only materialize the opencode directory, not all of ~/.config.
  mkdir -p "$HOME/.config"

  sync_instructions "$HOME/.config/opencode" "AGENTS.md"
  sync_skills "$HOME/.config/opencode"
  sync_optional_file "$OPENCODE_DIR/.gitignore" "$HOME/.config/opencode/.gitignore"
  sync_optional_file "$OPENCODE_DIR/package.json" "$HOME/.config/opencode/package.json"
  sync_optional_file "$OPENCODE_DIR/package-lock.json" "$HOME/.config/opencode/package-lock.json"
  sync_file "$OPENCODE_DIR/opencode.json" "$HOME/.config/opencode/opencode.json"
  sync_dir "$OPENCODE_DIR/plugin" "$HOME/.config/opencode/plugin"
}

sync_pi() {
  materialize_dir "$HOME/.pi"

  sync_instructions "$HOME/.pi/agent" "AGENTS.md"
  sync_skills "$HOME/.pi/agent"
  sync_file "$PI_DIR/settings.json" "$HOME/.pi/agent/settings.json"
  sync_dir "$PI_DIR/agents" "$HOME/.pi/agent/agents"
  sync_dir "$PI_DIR/extensions" "$HOME/.pi/agent/extensions"
  sync_dir "$PI_DIR/prompts" "$HOME/.pi/agent/prompts"
  sync_dir "$PI_DIR/themes" "$HOME/.pi/agent/themes"
}

validate_sources
sync_codex
sync_claude
sync_opencode
sync_pi
