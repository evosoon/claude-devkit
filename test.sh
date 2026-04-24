#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
PASS=0
FAIL=0
TOTAL=0

pass() { ((PASS++)); ((TOTAL++)); echo "  ✓ $1"; }
fail() { ((FAIL++)); ((TOTAL++)); echo "  ✗ $1"; }

echo "=== claude-devkit tests ==="
echo ""

# --- Command files exist and have correct frontmatter ---
echo "# Command files"

for skill in save recap; do
  file="$REPO_DIR/.claude/commands/${skill}.md"
  if [ -f "$file" ]; then
    pass "$skill.md exists"
  else
    fail "$skill.md missing"
    continue
  fi
  if head -1 "$file" | grep -q "^---$"; then
    pass "$skill.md has frontmatter"
  else
    fail "$skill.md missing frontmatter"
  fi
  if grep -q "^name: $skill$" "$file"; then
    pass "$skill.md name field correct"
  else
    fail "$skill.md name field incorrect"
  fi
  if grep -q "^description:" "$file"; then
    pass "$skill.md has description"
  else
    fail "$skill.md missing description"
  fi
done

echo ""

# --- Install ---
echo "# Install"

# Clean any existing links first
for skill in save recap; do
  target="$CLAUDE_DIR/commands/${skill}.md"
  [ -L "$target" ] && rm "$target"
done

"$REPO_DIR/install.sh" > /dev/null 2>&1

for skill in save recap; do
  target="$CLAUDE_DIR/commands/${skill}.md"
  if [ -L "$target" ]; then
    pass "install: $skill.md symlink created"
    link=$(readlink "$target")
    if [[ "$link" == "$REPO_DIR"* ]]; then
      pass "install: $skill.md points to repo"
    else
      fail "install: $skill.md points elsewhere: $link"
    fi
  else
    fail "install: $skill.md symlink missing"
  fi
done

echo ""

# --- Uninstall ---
echo "# Uninstall"

"$REPO_DIR/uninstall.sh" > /dev/null 2>&1

for skill in save recap; do
  target="$CLAUDE_DIR/commands/${skill}.md"
  if [ -L "$target" ]; then
    fail "uninstall: $skill.md symlink still exists"
  else
    pass "uninstall: $skill.md symlink removed"
  fi
done

echo ""

# --- Backup/restore ---
echo "# Backup & restore"

# Create a dummy file to test backup
mkdir -p "$CLAUDE_DIR/commands"
echo "original" > "$CLAUDE_DIR/commands/save.md"

"$REPO_DIR/install.sh" > /dev/null 2>&1

if [ -f "$CLAUDE_DIR/commands/save.md.bak" ]; then
  pass "install: backup created for existing file"
else
  fail "install: no backup for existing file"
fi

"$REPO_DIR/uninstall.sh" > /dev/null 2>&1

if [ -f "$CLAUDE_DIR/commands/save.md" ] && [ "$(cat "$CLAUDE_DIR/commands/save.md")" = "original" ]; then
  pass "uninstall: backup restored"
else
  fail "uninstall: backup not restored"
fi

# Cleanup
rm -f "$CLAUDE_DIR/commands/save.md" "$CLAUDE_DIR/commands/save.md.bak"

echo ""

# --- No extra files ---
echo "# Clean project structure"

extra_dirs=".claude/scripts .claude/decisions .claude/snapshots docs agents"
for dir in $extra_dirs; do
  if [ -d "$REPO_DIR/$dir" ]; then
    fail "stale directory exists: $dir"
  else
    pass "no stale directory: $dir"
  fi
done

extra_files=".claude/context.md .claude/project.yaml .claude/settings.local.json"
for f in $extra_files; do
  if [ -f "$REPO_DIR/$f" ]; then
    fail "stale file exists: $f"
  else
    pass "no stale file: $f"
  fi
done

echo ""

# --- Setup and hook scripts ---
echo "# Setup and hook scripts"

if [ -x "$REPO_DIR/setup-reminder.sh" ]; then
  pass "setup-reminder.sh exists and is executable"
else
  fail "setup-reminder.sh missing or not executable"
fi

if [ -x "$REPO_DIR/hooks/remind-save.sh" ]; then
  pass "hooks/remind-save.sh exists and is executable"
else
  fail "hooks/remind-save.sh missing or not executable"
fi

if [ -f "$REPO_DIR/.claude/settings.json.example" ]; then
  pass ".claude/settings.json.example exists"
else
  fail ".claude/settings.json.example missing"
fi

echo ""

# --- New directory structure ---
echo "# Directory structure"

if [ -d "$REPO_DIR/.claude/active" ]; then
  pass ".claude/active/ directory exists"
else
  fail ".claude/active/ directory missing"
fi

if [ -d "$REPO_DIR/.claude/docs/planning" ]; then
  pass ".claude/docs/planning/ directory exists"
else
  fail ".claude/docs/planning/ directory missing"
fi

if [ -d "$REPO_DIR/.claude/docs/archive" ]; then
  pass ".claude/docs/archive/ directory exists"
else
  fail ".claude/docs/archive/ directory missing"
fi

# Check key files exist
if [ -f "$REPO_DIR/.claude/docs/planning/roadmap.md" ]; then
  pass "docs/planning/roadmap.md exists"
else
  fail "docs/planning/roadmap.md missing"
fi

if [ -f "$REPO_DIR/.claude/docs/planning/constraints.md" ]; then
  pass "docs/planning/constraints.md exists"
else
  fail "docs/planning/constraints.md missing"
fi

if [ -f "$REPO_DIR/.claude/docs/planning/architecture.md" ]; then
  pass "docs/planning/architecture.md exists"
else
  fail "docs/planning/architecture.md missing"
fi

if [ -f "$REPO_DIR/.claude/docs/archive/decisions.md" ]; then
  pass "docs/archive/decisions.md exists"
else
  fail "docs/archive/decisions.md missing"
fi

echo ""

# --- Summary ---
echo "=== $TOTAL tests: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
