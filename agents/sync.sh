#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$#" -ne 0 ]; then
  printf 'Usage: %s\n' "$0" >&2
  exit 1
fi

link() {
  local source_path="$1"
  local target_path="$2"

  if [ ! -e "$source_path" ]; then
    printf 'Missing source: %s\n' "$source_path" >&2
    exit 1
  fi
  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
    return
  fi
  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    printf 'Refusing to overwrite existing path: %s\n' "$target_path" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$target_path")"
  ln -s "$source_path" "$target_path"
}

link "$SCRIPT_DIR/AGENTS.md" "$HOME/.codex/AGENTS.md"
link "$SCRIPT_DIR/AGENTS.md" "$HOME/.claude/CLAUDE.md"
link "$SCRIPT_DIR/AGENTS.md" "$HOME/.config/maki/AGENTS.md"
link "$SCRIPT_DIR/AGENTS.md" "$HOME/.pi/agent/AGENTS.md"

link "$SCRIPT_DIR/guidance" "$HOME/.codex/guidance"
link "$SCRIPT_DIR/guidance" "$HOME/.claude/guidance"
link "$SCRIPT_DIR/guidance" "$HOME/.config/maki/guidance"
link "$SCRIPT_DIR/guidance" "$HOME/.pi/agent/guidance"

link "$SCRIPT_DIR/skills" "$HOME/.agents/skills"
link "$SCRIPT_DIR/skills" "$HOME/.claude/skills"
