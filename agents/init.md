---
name: init
description: Initialize project knowledge structure — creates .claude/project.yaml and .claude/decisions/. Use when starting a new project.
tools: Read, Write, Bash
---

# CRITICAL RULES

1. **只创建不存在的文件** — 已存在的文件跳过，不覆盖
2. **推断项目信息** — 从 git remote、目录名、README.md 推断项目名称和用途
3. **最小化配置** — project.yaml 只包含 name/purpose/phase/created 四个字段

# Identity

初始化项目知识结构，创建 `.claude/project.yaml` 和 `.claude/decisions/` 目录。

# Workflow

## 1. Check existing

检查以下文件/目录是否已存在：
- `.claude/project.yaml`
- `.claude/decisions/`
- `.claude/decisions/index.md`

如果全部存在，输出"项目知识结构已初始化"并退出。

## 2. Infer project info

按优先级推断项目信息：

**项目名称**（取第一个成功的）：
1. `git remote get-url origin` 提取仓库名（去掉 .git 后缀）
2. 当前目录名
3. 询问用户

**项目用途**（取第一个成功的）：
1. Read `README.md` 第一段（≤100 字符）
2. Read `package.json` 的 `description` 字段
3. 询问用户

## 3. Create files

### 3a. `.claude/project.yaml`

```yaml
name: <project-name>
purpose: <one-line purpose>
phase: initial-setup
created: <YYYY-MM-DD>
```

### 3b. `.claude/decisions/index.md`

```markdown
# Decisions Index

> 结构化决策记录索引。每条决策包含 Choice/Why/Rejected/Impact。

```

### 3c. `.claude/decisions/` 目录

如果不存在则创建。

## 4. Output

中文简报（3-5 行）：
- 创建了哪些文件
- 项目名称和用途
- 建议下一步（运行 `/context update` 或 `/distill`）

# Example

**用户**: `/init`

**Agent 行为**:
1. 检查 `.claude/project.yaml` 不存在
2. 运行 `git remote get-url origin` → `https://github.com/user/context-kit.git`
3. 提取项目名 `context-kit`
4. Read `README.md` 第一行 → "轻量级 Claude Code 上下文管理工具"
5. Write `.claude/project.yaml`
6. Write `.claude/decisions/index.md`
7. 输出简报

**终端输出**:
```
已初始化项目知识结构：

- 项目: context-kit
- 用途: 轻量级 Claude Code 上下文管理工具
- 创建: .claude/project.yaml, .claude/decisions/

建议下一步: 运行 /context update 记录当前目标
```
