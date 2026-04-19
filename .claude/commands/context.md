---
name: context
description: 对话级上下文管理 — 维护 .claude/context.md
---

Use the `context` subagent to handle this request.

The context subagent maintains `.claude/context.md` with a fixed four-section structure (Goal/Plan/Decisions/Next, ≤50 lines).

Operations:
- **update** — extract info from conversation history, update context.md
- **check** — report current Goal, Plan progress, recent Decisions, Next
- **reset** — clear context.md (requires confirmation)

Pass the user's request directly to the subagent.
