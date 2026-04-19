---
name: recap
description: 跨会话恢复 — 快速回到工作状态
---

Use the `recap` subagent to handle this request.

The recap subagent reads snapshots, context.md, and git state, then outputs a concise Chinese briefing (≤25 lines) to help you resume work.

Typical usage:
- `/recap` — at session start, see where you left off
- "继续上次的工作" — resume previous session
