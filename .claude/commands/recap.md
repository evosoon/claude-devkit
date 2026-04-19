---
name: recap
description: Cross-session recovery briefing — reads snapshots/context/git, outputs ≤25 line Chinese summary. NOT for updating context.md, use recap subagent.
---

Use the `recap` subagent to handle this request.

The recap subagent reads snapshots, context.md, and git state, then outputs a concise Chinese briefing (≤25 lines) to help you resume work.

Typical usage:
- `/recap` — at session start, see where you left off
- "继续上次的工作" — resume previous session
