---
name: snapshot
description: 生成项目快照 — 记录当前项目状态到 .claude/snapshots/
---

Use the `snapshot` subagent to handle this request.

The snapshot subagent reads trace files, git state, and context.md, then writes a structured snapshot to `.claude/snapshots/<date>.md`.

Typical usage:
- `/snapshot` — save current project state before ending a session
