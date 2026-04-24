# 决策记录

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

_此文件只追加，不修改已有记录_
