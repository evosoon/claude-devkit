#!/bin/bash
set -euo pipefail

PASS=0
FAIL=0
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

pass() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

# ---- Install / Uninstall ----
echo "=== Install ==="

FAKE_HOME="$TMPDIR/home"
mkdir -p "$FAKE_HOME/.claude/agents"
mkdir -p "$FAKE_HOME/.claude/commands"
export HOME="$FAKE_HOME"

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Test: install creates symlinks
"$REPO_DIR/install.sh" > /dev/null
[ -L "$FAKE_HOME/.claude/agents/context.md" ] && pass "agent symlink created" || fail "agent symlink missing"
[ -L "$FAKE_HOME/.claude/commands/context.md" ] && pass "command symlink created" || fail "command symlink missing"
[ -L "$FAKE_HOME/.claude/scripts" ] && pass "scripts symlink created" || fail "scripts symlink missing"

# Test: symlinks point to repo
link=$(readlink "$FAKE_HOME/.claude/agents/context.md")
[[ "$link" == "$REPO_DIR/agents/context.md" ]] && pass "agent symlink target correct" || fail "agent symlink target wrong: $link"
cmd_link=$(readlink "$FAKE_HOME/.claude/commands/context.md")
[[ "$cmd_link" == "$REPO_DIR/.claude/commands/context.md" ]] && pass "command symlink target correct" || fail "command symlink target wrong: $cmd_link"

# Test: install preserves existing non-symlink files
rm -rf "$FAKE_HOME/.claude"
mkdir -p "$FAKE_HOME/.claude/agents"
echo "user content" > "$FAKE_HOME/.claude/agents/context.md"
"$REPO_DIR/install.sh" > /dev/null
[ -f "$FAKE_HOME/.claude/agents/context.md.bak" ] && pass "backup created for existing file" || fail "backup not created"

# Test: uninstall removes symlinks
"$REPO_DIR/uninstall.sh" > /dev/null
[ ! -L "$FAKE_HOME/.claude/agents/context.md" ] && pass "agent symlink removed" || fail "agent symlink still exists"
[ ! -L "$FAKE_HOME/.claude/commands/context.md" ] && pass "command symlink removed" || fail "command symlink still exists"
[ ! -L "$FAKE_HOME/.claude/scripts" ] && pass "scripts symlink removed" || fail "scripts symlink still exists"

# Test: uninstall restores backup
[ -f "$FAKE_HOME/.claude/agents/context.md" ] && pass "backup restored" || fail "backup not restored"
content=$(cat "$FAKE_HOME/.claude/agents/context.md")
[ "$content" = "user content" ] && pass "restored content matches" || fail "restored content differs"

echo ""
echo "=== Trace Hook ==="

TRACE_DIR="$TMPDIR/project/.claude/trace"
mkdir -p "$TMPDIR/project/.claude/scripts"
cp "$REPO_DIR/.claude/scripts/hook-post-tool.sh" "$TMPDIR/project/.claude/scripts/"

cd "$TMPDIR/project"

# Test: Edit tool via stdin JSON
echo '{"session_id":"test-001","tool_name":"Edit","tool_input":{"file_path":"src/main.ts"}}' | bash .claude/scripts/hook-post-tool.sh
[ -f ".claude/trace/test-001.jsonl" ] && pass "trace file created" || fail "trace file missing"

line=$(cat .claude/trace/test-001.jsonl)
echo "$line" | jq . > /dev/null 2>&1 && pass "trace line is valid JSON" || fail "trace line is invalid JSON"

tool=$(echo "$line" | jq -r '.tool')
file=$(echo "$line" | jq -r '.file')
[ "$tool" = "Edit" ] && pass "trace tool field correct" || fail "trace tool field: $tool"
[ "$file" = "src/main.ts" ] && pass "trace file field correct" || fail "trace file field: $file"

# Test: Write tool appends
echo '{"session_id":"test-001","tool_name":"Write","tool_input":{"file_path":"README.md"}}' | bash .claude/scripts/hook-post-tool.sh
count=$(wc -l < .claude/trace/test-001.jsonl)
[ "$count" -eq 2 ] && pass "trace appends (2 lines)" || fail "trace line count: $count"

# Test: Bash success
echo '{"session_id":"test-001","tool_name":"Bash","tool_input":{"command":"echo hello"},"tool_response":{"exit_code":0}}' | bash .claude/scripts/hook-post-tool.sh
line=$(tail -1 .claude/trace/test-001.jsonl)
cmd=$(echo "$line" | jq -r '.cmd')
exit_code=$(echo "$line" | jq -r '.exit')
[[ "$cmd" == "echo hello" ]] && pass "Bash cmd captured" || fail "Bash cmd: $cmd"
[ "$exit_code" -eq 0 ] && pass "Bash exit code correct" || fail "Bash exit: $exit_code"

# Test: Bash failure with stderr
echo '{"session_id":"test-001","tool_name":"Bash","tool_input":{"command":"npm test"},"tool_response":{"exit_code":1,"stderr":"TypeError: Cannot read property\nline 42\nstack trace"}}' | bash .claude/scripts/hook-post-tool.sh
line=$(tail -1 .claude/trace/test-001.jsonl)
err=$(echo "$line" | jq -r '.err')
exit_code=$(echo "$line" | jq -r '.exit')
[ "$exit_code" -eq 1 ] && pass "Bash failure exit code" || fail "exit: $exit_code"
[[ "$err" == *"TypeError"* ]] && pass "Bash stderr captured" || fail "err: $err"

# Test: TaskUpdate
echo '{"session_id":"test-001","tool_name":"TaskUpdate","tool_input":{"taskId":"task-123","status":"completed"}}' | bash .claude/scripts/hook-post-tool.sh
line=$(tail -1 .claude/trace/test-001.jsonl)
task=$(echo "$line" | jq -r '.task')
status=$(echo "$line" | jq -r '.status')
[ "$task" = "task-123" ] && pass "TaskUpdate task field" || fail "task: $task"
[ "$status" = "completed" ] && pass "TaskUpdate status field" || fail "status: $status"

# Test: different session gets different file
echo '{"session_id":"test-002","tool_name":"Edit","tool_input":{"file_path":"test.ts"}}' | bash .claude/scripts/hook-post-tool.sh
[ -f ".claude/trace/test-002.jsonl" ] && pass "separate session file created" || fail "separate session file missing"

# Test: size guard (create file just over 5MB threshold)
# Generate a line ~5KB long, repeat ~1100 times to exceed 5MB
long_value=$(printf '%0.s0' {1..5000})
for i in {1..1100}; do
  echo "{\"ts\":\"2026-04-19T10:00:00Z\",\"tool\":\"Edit\",\"file\":\"$long_value\"}" >> .claude/trace/test-001.jsonl
done
echo '{"session_id":"test-001","tool_name":"Edit","tool_input":{"file_path":"trigger.ts"}}' | bash .claude/scripts/hook-post-tool.sh
count=$(wc -l < .claude/trace/test-001.jsonl | tr -d ' ')
[ "$count" -le 1010 ] && pass "size guard truncates to ~1000 lines" || fail "line count after guard: $count"

echo ""
echo "=== Results ==="
echo "  $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
