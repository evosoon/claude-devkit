# Decisions Index

> 结构化决策记录索引。每条决策包含 Choice/Why/Rejected/Impact。

- [2026-04-19 three-agent-architecture](three-agent-architecture.md) — 三级知识体系与五 Agent 单一职责架构
- [2026-04-19 context-format](context-format.md) — context.md 采用固定六段式结构，上限 60 行
- [2026-04-19 hook-stdin-json](hook-stdin-json.md) — Trace hook 采用 stdin JSON 协议，纯记录不处理
- [2026-04-19 minimal-automation](minimal-automation.md) — 最小自动化策略：hook 只追踪，其余手动触发
- [2026-04-19 symlink-install](symlink-install.md) — 用符号链接部署到 ~/.claude/，带备份恢复机制
- [2026-04-19 graceful-degradation](graceful-degradation.md) — 全链路降级优先：数据源缺失跳过不报错
