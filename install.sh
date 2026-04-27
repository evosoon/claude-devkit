#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "claude-devkit: installing to $CLAUDE_DIR/commands/ and $CLAUDE_DIR/skills/"

mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/skills"

for cmd in "$REPO_DIR"/.claude/commands/*.md; do
  [ -f "$cmd" ] || continue
  name=$(basename "$cmd")

  # Link to both commands/ and skills/
  for target_dir in commands skills; do
    target="$CLAUDE_DIR/$target_dir/$name"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      cp "$target" "${target}.bak"
      echo "  backup: $target_dir/$name → ${name}.bak"
    fi
    ln -sfn "$cmd" "$target"
    echo "  linked: $target_dir/$name"
  done
done

echo ""
echo "done. commands: /save, /recap"
echo "uninstall: $REPO_DIR/uninstall.sh"
