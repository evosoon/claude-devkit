#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "context-kit: uninstalling from $CLAUDE_DIR"

# Remove symlink if it points to this repo, restore backup if exists
unlink_with_restore() {
  local target="$1" label="$2"
  if [ -L "$target" ]; then
    local link_target=$(readlink "$target")
    if [[ "$link_target" == "$REPO_DIR"* ]]; then
      rm "$target"
      echo "  removed: $label"
      if [ -e "${target}.bak" ]; then
        mv "${target}.bak" "$target"
        echo "  restored: ${label}.bak → $label"
      fi
    fi
  fi
}

# Unlink agents
for agent in "$REPO_DIR"/agents/*.md; do
  [ -f "$agent" ] || continue
  name=$(basename "$agent")
  unlink_with_restore "$CLAUDE_DIR/agents/$name" "agents/$name"
done

# Unlink commands
for cmd in "$REPO_DIR"/.claude/commands/*.md; do
  [ -f "$cmd" ] || continue
  name=$(basename "$cmd")
  unlink_with_restore "$CLAUDE_DIR/commands/$name" "commands/$name"
done

# Unlink scripts
unlink_with_restore "$CLAUDE_DIR/scripts" "scripts/"

echo ""
echo "done."
