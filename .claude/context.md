# Context

## Goal
构建 context-kit：轻量级 Claude Code 上下文管理工具，提供会话级记忆、快照归档、项目回顾与全局知识提取能力。

## Plan
- [x] Phase 1: 核心 agents 开发（context / snapshot / recap）
- [x] Phase 2: trace hook + install/uninstall 脚本 + 项目结构完善
- [x] Phase 3-prep: 初始提交（commit 0aa5769，15 files，786 lines）
- [ ] Phase 3: extract agent（从快照中提取全局知识写入 CLAUDE.md）
- [ ] Phase 4: 文档完善与发布准备

## Changes
- .claude/commands/recap.md (修改中)
- .claude/commands/snapshot.md (修改中)
- .claude/context.md (修改中)
- agents/context.md (修改中)

## Blockers
（无）

## Decisions
- 三 agent 架构：context（会话记忆）、snapshot（快照归档）、recap（项目回顾）
- trace hook 自动在会话结束时触发快照
- install.sh / uninstall.sh 管理安装卸载
- settings.local.json 配置 agent 权限
- context.md 采用固定六段式结构（Goal/Plan/Changes/Blockers/Decisions/Next），上限 60 行

## Next
启动 Phase 3：设计并实现 extract agent，从 snapshots 提取全局知识写入 CLAUDE.md
