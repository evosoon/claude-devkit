#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "claude-devkit: uninstalling from $CLAUDE_DIR/commands/"

for cmd in "$REPO_DIR"/.claude/commands/*.md; do
  [ -f "$cmd" ] || continue
  name=$(basename "$cmd")
  target="$CLAUDE_DIR/commands/$name"
  if [ -L "$target" ]; then
    link_target=$(readlink "$target")
    if [[ "$link_target" == "$REPO_DIR"* ]]; then
      rm "$target"
      echo "  removed: $name"
      if [ -e "${target}.bak" ]; then
        mv "${target}.bak" "$target"
        echo "  restored: ${name}.bak → $name"
      fi
    fi
  fi
done

echo ""
echo "done."
