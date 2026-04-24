#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo "claude-devkit: 设置自动提醒..."

# Create hooks directory
mkdir -p "$HOOKS_DIR"

# Copy hook script
cp "$REPO_DIR/hooks/remind-save.sh" "$HOOKS_DIR/remind-save.sh"
chmod +x "$HOOKS_DIR/remind-save.sh"
echo "  已安装: remind-save.sh → $HOOKS_DIR/"

# Update settings.json
if [[ ! -f "$SETTINGS_FILE" ]]; then
  # Create new settings.json
  cat > "$SETTINGS_FILE" <<'EOF'
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/remind-save.sh"
          }
        ]
      }
    ]
  }
}
EOF
  echo "  已创建: $SETTINGS_FILE"
else
  echo "  ⚠️  $SETTINGS_FILE 已存在"
  echo "  请手动添加以下配置到 hooks.Stop 数组："
  echo ""
  cat <<'EOF'
  {
    "hooks": [
      {
        "type": "command",
        "command": "bash ~/.claude/hooks/remind-save.sh"
      }
    ]
  }
EOF
  echo ""
fi

echo ""
echo "✓ 完成！每次 Claude 回复后会检查是否需要提醒 /save"
echo ""
echo "卸载: rm ~/.claude/hooks/remind-save.sh"
echo "      并从 ~/.claude/settings.json 中移除对应的 hook 配置"
