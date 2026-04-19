---
name: distill
description: Distill decisions from snapshots — extracts key decisions to .claude/decisions/
---

Use the `distill` subagent to handle this request.

The distill subagent reads snapshots and context.md, identifies key decisions (tech choices, architecture changes, problem solutions), and writes structured decision records to `.claude/decisions/`.

Typical usage:
- `/distill` — after completing a phase, extract decisions for future reference
