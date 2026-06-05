#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_NAME="ui-check"

install_skill() {
  local base_dir="$1"
  local target_dir="${base_dir}/${SKILL_NAME}"

  mkdir -p "$base_dir"
  rm -rf "$target_dir"
  mkdir -p "$target_dir"

  cp "$SCRIPT_DIR/SKILL.md" "$target_dir/SKILL.md"
  cp -R "$SCRIPT_DIR/assets" "$target_dir/assets"
  cp -R "$SCRIPT_DIR/references" "$target_dir/references"

  echo "Installed to $target_dir"
}

install_skill "$HOME/.codex/skills"

if [ -d "$HOME/.claude/skills" ]; then
  install_skill "$HOME/.claude/skills"
fi

echo
echo "Skill installation complete."
echo "Trigger with:"
echo "用 ui-check 这个 skill，帮我做设计验收走查。"
