#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "context-kit: deploying to $CLAUDE_DIR"

# Backup if exists and is not a symlink, then link
link_with_backup() {
  local source="$1" target="$2" label="$3"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "  backup: $label → ${label}.bak"
    [ -d "$target" ] && mv "$target" "${target}.bak" || cp "$target" "${target}.bak"
  fi
  ln -sfn "$source" "$target"
  echo "  linked: $label"
}

mkdir -p "$CLAUDE_DIR/agents"
mkdir -p "$CLAUDE_DIR/commands"

# Link agents (preserve user's custom agents)
for agent in "$REPO_DIR"/agents/*.md; do
  [ -f "$agent" ] || continue
  name=$(basename "$agent")
  link_with_backup "$agent" "$CLAUDE_DIR/agents/$name" "agents/$name"
done

# Link commands
for cmd in "$REPO_DIR"/.claude/commands/*.md; do
  [ -f "$cmd" ] || continue
  name=$(basename "$cmd")
  link_with_backup "$cmd" "$CLAUDE_DIR/commands/$name" "commands/$name"
done

# Link hook scripts
link_with_backup "$REPO_DIR/.claude/scripts" "$CLAUDE_DIR/scripts" "scripts/"

echo ""
echo "done. to uninstall: $REPO_DIR/uninstall.sh"
