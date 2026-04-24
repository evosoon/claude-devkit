---
name: recap
description: 用户明确输入 /recap 时触发 — 读取 active/docs/git，输出中文简报，快速回到工作状态。不要在其他命令的输出中自动触发。
---

# /recap — 恢复工作上下文

新会话开始时，读取项目上下文资产和 git 状态，输出简报帮助快速恢复。

## 执行步骤

1. **读取上下文文件**（按优先级）：
   - `.claude/active/state.md` — 上次保存的工作状态
   - `.claude/docs/archive/decisions.md` — 最近 10 条决策记录
   - `.claude/docs/planning/constraints.md` — 当前约束
   - `.claude/docs/planning/roadmap.md` — 项目路线图（可选）

2. **读取 git 状态**：
   - `git log --oneline -10` — 最近提交
   - `git diff --stat` — 未提交的变更
   - `git branch --show-current` — 当前分支

3. **综合输出中文简报**（≤20 行），包含：
   - 上次在做什么（from active/state.md）
   - 做到哪了、还剩什么（from active/state.md 进度）
   - 近期关键决策（from docs/archive/decisions.md，只列最相关的 2-3 条）
   - 当前约束（from docs/planning/constraints.md，如果有重要约束）
   - 当前代码状态（from git）
   - 建议的下一步动作

4. 简报输出后**直接进入工作状态**，不需要用户额外指令。

## 降级策略

- **有 active/state.md + docs/**：完整简报
- **只有 active/state.md**：简报 + 提示"尚无文档记录"
- **只有 docs/**：从文档推断上下文 + git 状态
- **都没有**：仅用 git log + diff 输出概要，并输出以下提醒：

```
⚠️ 未找到上下文文件 - 决策可能已经流失

💡 强烈建议：会话结束前运行 /save
💡 可选：运行 ./setup-reminder.sh 启用自动提醒
```

## 注意事项

- 简报必须用中文
- 关注"接下来该做什么"而非"之前做了什么"——面向行动，不是回顾
- 如果 active/state.md 中有阻塞项，优先提醒
- docs/planning/ 的内容是"活跃文档"，可能包含未来计划，注意区分当前任务和未来计划
