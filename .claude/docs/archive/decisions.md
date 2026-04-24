# 决策记录

## 2026-04-23 Rewrite: 5 commands + 5 agents + trace hook → 2 skills (/save, /recap)

**Context**: 原方案过于复杂，用户心智负担重  
**Decision**: 简化为 2 个核心命令  
**Alternatives**: 
- 保持多命令体系：更灵活但更复杂
- 单命令：过于简化

**Rationale**: 
- 聚焦核心场景：会话结束锚定、会话开始恢复
- 降低学习成本
- 符合极简主义原则

**Consequences**: 
- 功能更聚焦
- 用户更容易上手
- 失去了一些灵活性（可接受）

---

## 2026-04-24 使用 docs/ 而非 memory/

**Context**: 需要命名持久化知识的目录  
**Decision**: 使用 `docs/` 而非 `memory/`  
**Alternatives**: 
- `memory/`: 更贴近"记忆"概念
- `knowledge/`: 更学术化
- `context/`: 与 active 混淆

**Rationale**: 
- `docs/` 是开发者熟悉的约定
- 暗示"文档化的知识"而非"原始记忆"
- 与 active（工作区）形成清晰对比

**Consequences**: 
- 用户心智负担低
- 与其他项目的 docs/ 可能冲突（但我们在 .claude/ 下，可接受）

---

## 2026-04-24 Planning vs Archive 分离

**Context**: docs/ 下需要组织结构  
**Decision**: 分为 `planning/`（活跃文档）和 `archive/`（历史记录）  
**Alternatives**: 
- 单层：所有文件平铺
- 按类型：decisions/, constraints/, understanding/

**Rationale**: 
- Planning/Archive 对应"笔记本/档案袋"的认知模型
- 时态清晰：现在/未来 vs 过去
- 操作语义：更新 vs 追加

**Consequences**: 
- 结构更清晰
- 增加了一层目录（可接受的复杂度）

---

## 2026-04-24 增强 /save 而非添加独立的 /save-suggest 命令

**Context**: 需要实现智能沉淀建议功能，面临是集成还是独立的选择  
**Decision**: 将智能建议集成到 /save 中作为可选步骤  
**Alternatives**: 
- 创建独立的 /save-suggest 命令：职责更清晰但违背极简原则
- 使用 --suggest 参数：Claude Code 不支持参数传递

**Rationale**: 
- 保持 2 个核心命令的极简原则（不超过 3 个）
- 建议是可选的辅助功能，不影响基础保存流程
- 用户可以通过"只保存 state"来跳过建议
- 减少用户需要记忆的命令数量

**Consequences**: 
- /save 的职责略微扩展，但仍然聚焦
- 用户体验更流畅（一个命令完成所有保存相关操作）
- 如果建议功能失败，不影响基础保存

---

_此文件只追加，不修改已有记录_
