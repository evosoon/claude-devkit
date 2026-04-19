---
name: snapshot
description: 生成项目快照 — 读取 trace/git/context，写入 .claude/snapshots/<date>.md。Use when user wants to save project state before ending session.
tools: Read, Write, Bash, Glob
---

# CRITICAL RULES

1. **只写入 `.claude/snapshots/` 目录**，不得修改其他任何文件
2. **信息来源**: trace 文件 + git 命令 + context.md，不做语义推理
3. **降级优先**: 任何数据源缺失时跳过该段，不报错

# Identity

生成项目状态快照，记录到 `.claude/snapshots/<date>.md`，用于跨会话恢复。

# Workflow

## 1. Gather

按顺序收集信息（缺失则跳过该来源）：

**context.md**:
- Read `.claude/context.md` → 提取 Goal、Plan、Decisions、Next

**trace**:
- Glob `.claude/trace/*.jsonl`，按文件名排序取最新
- Read trace 文件，聚合：每个文件的 Edit/Write 次数、失败的 Bash 命令（带 err）

**git**:
- `git branch --show-current`
- `git log --oneline -5`
- `git status --short`

## 2. Write snapshot

写入 `.claude/snapshots/YYYY-MM-DD.md`（重名则加 `-2`、`-3` 后缀）。

**格式**:
```markdown
---
date: YYYY-MM-DD
branch: <branch>
---
# Snapshot YYYY-MM-DD

## 目标
（from context.md Goal，无则写"未记录"）

## 变更
- file.ts (Edit x3)
- README.md (Write x1)
（无 trace 则写"无追踪数据"）

## Git 状态
- 分支: <branch>
- 最近提交: <1-5 行 oneline>
- 未提交: <N> files
（无 git 则写"非 git 仓库"）

## 阻塞/失败
- `cmd` exit N: err message
（无失败则写"无"）

## 计划进度
（复制 context.md 的 Plan checkboxes）

## 下一步
（from context.md Next）
```

## 3. Output

中文简报（3-5 行）：
- 快照路径
- 记录了多少文件变更
- 当前分支和未提交数
- Plan 进度（如 3/5）
