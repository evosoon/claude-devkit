#!/bin/bash
# Trace hook: append tool calls to .claude/trace/<session>.jsonl
# Triggered by PostToolUse on Edit|Write|Bash|TaskUpdate
# Single responsibility: record only, never process.
# Protocol: Claude Code passes hook data via stdin JSON.

set -euo pipefail

input=$(cat)
session_id=$(jq -r '.session_id' <<<"$input")
tool=$(jq -r '.tool_name' <<<"$input")
ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

trace_dir=".claude/trace"
mkdir -p "$trace_dir"
trace_file="${trace_dir}/${session_id}.jsonl"

# --- Trace Append (per-tool enrichment) ---
case "$tool" in
  Edit|Write)
    file=$(jq -r '.tool_input.file_path' <<<"$input")
    jq -nc --arg ts "$ts" --arg tool "$tool" --arg file "$file" \
      '{ts: $ts, tool: $tool, file: $file}' >> "$trace_file"
    ;;
  Bash)
    cmd=$(jq -r '.tool_input.command' <<<"$input" | cut -c1-200)
    exit_code=$(jq -r '.tool_response.exit_code // 0' <<<"$input")
    if [ "$exit_code" -ne 0 ] 2>/dev/null; then
      err=$(jq -r '(.tool_response.stderr // "") | split("\n") | .[0:3] | join(" | ")' <<<"$input" 2>/dev/null | cut -c1-200 || echo "")
      jq -nc --arg ts "$ts" --arg cmd "$cmd" --argjson exit "$exit_code" --arg err "$err" \
        '{ts: $ts, tool: "Bash", cmd: $cmd, exit: $exit, err: $err}' >> "$trace_file"
    else
      jq -nc --arg ts "$ts" --arg cmd "$cmd" --argjson exit "${exit_code:-0}" \
        '{ts: $ts, tool: "Bash", cmd: $cmd, exit: $exit}' >> "$trace_file"
    fi
    ;;
  TaskUpdate)
    task_id=$(jq -r '.tool_input.taskId' <<<"$input")
    status=$(jq -r '.tool_input.status // empty' <<<"$input")
    jq -nc --arg ts "$ts" --arg task "$task_id" --arg status "$status" \
      '{ts: $ts, tool: "TaskUpdate", task: $task, status: $status}' >> "$trace_file"
    ;;
  *)
    # Unknown tool — record minimal trace
    jq -nc --arg ts "$ts" --arg tool "$tool" \
      '{ts: $ts, tool: $tool}' >> "$trace_file"
    ;;
esac

# --- Size Guard: truncate to last 1000 lines when > 5MB ---
if [ -f "$trace_file" ]; then
  size=$(wc -c < "$trace_file" | tr -d ' ')
  if [ "$size" -gt 5242880 ]; then
    tail -1000 "$trace_file" > "${trace_file}.tmp"
    mv "${trace_file}.tmp" "$trace_file"
  fi
fi
