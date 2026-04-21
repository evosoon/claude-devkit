# Context

## Goal
构建 context-kit：轻量级 Claude Code 上下文管理工具，提供会话级记忆、快照归档、项目回顾与全局知识提取能力。

## Plan
- [x] Phase 1: 核心 agents 开发（context / snapshot / recap）
- [x] Phase 2: trace hook + install/uninstall 脚本 + 项目结构完善
- [x] Phase 3-prep: 初始提交（commit 0aa5769，15 files，786 lines）
- [x] Phase 3: project-level assets（init + distill agents，commit 092d771）
- [ ] Phase 4: 文档完善与发布准备

## Changes
- .claude/commands/ctx.md (从 context.md 重命名)
- agents/ctx.md (从 context.md 重命名，更新 name 字段)

## Blockers
（无）

## Decisions
- 三 agent 架构：context（会话记忆）、snapshot（快照归档）、recap（项目回顾）
- trace hook 自动在会话结束时触发快照
- install.sh / uninstall.sh 管理安装卸载
- settings.local.json 配置 agent 权限
- context.md 采用固定六段式结构（Goal/Plan/Changes/Blockers/Decisions/Next），上限 60 行
- /context 命令与 Claude Code 内置命令冲突，重命名为 /ctx（commit 8658ba7）

## Next
推进 Phase 4：文档完善与发布准备
