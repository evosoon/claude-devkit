#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "claude-devkit: uninstalling from $CLAUDE_DIR/commands/ and $CLAUDE_DIR/skills/"

for cmd in "$REPO_DIR"/.claude/commands/*.md; do
  [ -f "$cmd" ] || continue
  name=$(basename "$cmd")

  # Remove from both commands/ and skills/
  for target_dir in commands skills; do
    target="$CLAUDE_DIR/$target_dir/$name"
    if [ -L "$target" ]; then
      link_target=$(readlink "$target")
      if [[ "$link_target" == "$REPO_DIR"* ]]; then
        rm "$target"
        echo "  removed: $target_dir/$name"
        if [ -e "${target}.bak" ]; then
          mv "${target}.bak" "$target"
          echo "  restored: $target_dir/${name}.bak → $name"
        fi
      fi
    fi
  done
done

echo ""
echo "done."
