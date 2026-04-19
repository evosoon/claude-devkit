---
name: snapshot
description: Generate project snapshot — reads trace/git/context, writes .claude/snapshots/<date>.md. NOT for context.md updates, use snapshot subagent.
---

Use the `snapshot` subagent to handle this request.

The snapshot subagent reads trace files, git state, and context.md, then writes a structured snapshot to `.claude/snapshots/<date>.md`.

Typical usage:
- `/snapshot` — save current project state before ending a session
