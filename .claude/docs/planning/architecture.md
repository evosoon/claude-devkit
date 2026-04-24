# 架构理解

## 核心机制

```
对话 → /save → active/state.md（覆写）
                ↓ 沉淀
              docs/archive/decisions.md（追加）
     ↓
   /recap → 读取 active/ + docs/ → 恢复上下文
```

## 关键设计

### Active vs Docs
- **Active**：易变，会话级，可丢弃（大脑+草稿纸）
- **Docs**：稳定，项目级，持久化（笔记本+档案袋）

### Planning vs Archive
- **Planning**：面向未来，可更新（roadmap, constraints, architecture）
- **Archive**：面向过去，只追加（decisions, explorations）

### 沉淀触发
- 自动建议：AI 检测信号（"选择 X 而非 Y"、"不能/必须"）
- 手动确认：用户决定是否沉淀
- 混合策略：平衡自动化和控制

## 数据流

1. **会话开始**：`/recap` 加载 docs/ → 初始化 active/
2. **工作中**：更新 active/state.md
3. **会话结束**：`/save` 提取 active/ → 沉淀到 docs/
4. **Git 提交**：docs/ 跨设备同步

## 目录结构

```
.claude/
├── active/              # 工作区（会话级）
│   ├── state.md        # 当前状态（覆写）
│   └── scratch.md      # 临时推演（可选）
└── docs/               # 文档区（项目级）
    ├── planning/       # 活跃文档（可更新）
    │   ├── roadmap.md
    │   ├── constraints.md
    │   └── architecture.md
    └── archive/        # 历史记录（只追加）
        └── decisions.md
```

_最后更新: 2026-04-24_
