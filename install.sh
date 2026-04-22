#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "claude-devkit: installing to $CLAUDE_DIR/commands/"

mkdir -p "$CLAUDE_DIR/commands"

for cmd in "$REPO_DIR"/.claude/commands/*.md; do
  [ -f "$cmd" ] || continue
  name=$(basename "$cmd")
  target="$CLAUDE_DIR/commands/$name"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    cp "$target" "${target}.bak"
    echo "  backup: $name → ${name}.bak"
  fi
  ln -sfn "$cmd" "$target"
  echo "  linked: $name"
done

echo ""
echo "done. commands: /save, /recap"
echo "uninstall: $REPO_DIR/uninstall.sh"
