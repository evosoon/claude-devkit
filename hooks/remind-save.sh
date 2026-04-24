#!/usr/bin/env bash
# Remind user to run /save if context is stale or missing

STATE_FILE=".claude/active/state.md"
THRESHOLD_MINUTES=30

if [[ ! -f "$STATE_FILE" ]]; then
  # No state file - first time or forgot to save
  cat <<'EOF'
{"systemMessage": "💡 提示：会话结束前记得运行 /save 保存上下文"}
EOF
  exit 0
fi

# Check if state file is older than threshold
if [[ -n $(find "$STATE_FILE" -mmin +$THRESHOLD_MINUTES 2>/dev/null) ]]; then
  cat <<'EOF'
{"systemMessage": "💡 提示：距离上次 /save 已超过 30 分钟"}
EOF
fi

exit 0
