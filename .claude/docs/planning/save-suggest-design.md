# /save --suggest 设计文档

## 目标

自动检测对话中值得沉淀到 docs/ 的内容，减少人工判断负担。

## 检测信号

### 1. 决策信号（Decision Signals）

**模式**：
- "选择 X 而非 Y"
- "采用 A 方案，放弃 B"
- "决定用 X，因为..."
- "最终选了 X"
- "X 比 Y 更合适"

**验证条件**（至少满足 2 个）：
- [ ] 有明确的选择（X）
- [ ] 有放弃的备选（Y）
- [ ] 有理由（because/因为）
- [ ] 影响范围 > 1 个文件
- [ ] 讨论时长 > 5 轮对话

**输出格式**：
```
【决策】<标题>
  选择：<X>
  放弃：<Y>
  理由：<why>
  → 建议追加到 docs/archive/decisions.md
```

### 2. 约束信号（Constraint Signals）

**模式**：
- "不能用 X 因为 Y"
- "必须满足 Z"
- "禁止 A"
- "要求 B"
- "限制 C"

**验证条件**：
- [ ] 有明确的约束类型（不能/必须/禁止）
- [ ] 有约束来源（技术/业务/团队）
- [ ] 影响未来决策

**输出格式**：
```
【约束】<类型>
  内容：<constraint>
  来源：<source>
  → 建议更新 docs/planning/constraints.md
```

### 3. 理解信号（Understanding Signals）

**模式**：
- "原来 X 是因为 Y"
- "理解了 A 的原理"
- "X 的工作机制是..."
- "为什么 X 这样设计"
- "X vs Y 的区别是..."

**验证条件**：
- [ ] 有深层解释（不是表面操作）
- [ ] 有认知模型或类比
- [ ] 可复用（不是一次性知识）

**输出格式**：
```
【理解】<主题>
  内容：<insight>
  → 建议更新 docs/planning/architecture.md
```

## 实现策略

### 方案 A：规则引擎（简单但脆弱）

```python
def detect_signals(conversation):
    signals = []
    
    # 决策模式
    decision_patterns = [
        r"选择\s+(.+?)\s+而非\s+(.+)",
        r"采用\s+(.+?)[，,]\s*放弃\s+(.+)",
        r"决定用\s+(.+?)[，,因为]\s+(.+)",
    ]
    
    # 约束模式
    constraint_patterns = [
        r"不能\s+(.+?)\s+因为\s+(.+)",
        r"必须\s+(.+)",
        r"禁止\s+(.+)",
    ]
    
    # 理解模式
    understanding_patterns = [
        r"原来\s+(.+?)\s+是因为\s+(.+)",
        r"理解了\s+(.+?)\s+的\s+(.+)",
        r"(.+?)\s+vs\s+(.+?)\s+的区别",
    ]
    
    for msg in conversation:
        for pattern in decision_patterns:
            if match := re.search(pattern, msg):
                signals.append(("decision", match.groups()))
        # ... 其他模式
    
    return signals
```

**优点**：快速、可预测  
**缺点**：容易误判、难以处理复杂语境

### 方案 B：LLM 判断（准确但慢）

```python
def detect_signals(conversation):
    prompt = f"""
    分析以下对话，提取值得沉淀的内容：
    
    {conversation}
    
    输出 JSON：
    {{
      "decisions": [
        {{"title": "...", "choice": "...", "alternatives": "...", "rationale": "..."}}
      ],
      "constraints": [
        {{"type": "...", "content": "...", "source": "..."}}
      ],
      "understanding": [
        {{"topic": "...", "insight": "..."}}
      ]
    }}
    """
    
    return llm.complete(prompt)
```

**优点**：准确、理解语境  
**缺点**：慢、成本高、不可预测

### 方案 C：混合（推荐）

```python
def detect_signals(conversation):
    # 1. 规则初筛（快速过滤明显的信号）
    candidates = rule_based_filter(conversation)
    
    # 2. LLM 确认（只对候选项判断）
    if len(candidates) > 0:
        confirmed = llm_validate(candidates, conversation)
        return confirmed
    
    return []
```

**优点**：平衡速度和准确性  
**缺点**：实现复杂度中等

## 用户交互流程

```
用户: /save --suggest

Claude:
  ✓ 已保存 active/state.md
  
  💡 检测到可沉淀内容：
  
  【决策】使用 docs/ 而非 memory/
    选择：docs/（开发者熟悉的约定）
    放弃：memory/（更贴近"记忆"概念）
    理由：降低用户心智负担
    → 建议追加到 docs/archive/decisions.md
  
  【约束】保持极简主义
    内容：文件数量最小化，避免过度设计
    来源：项目定位（个人开发者工具）
    → 建议更新 docs/planning/constraints.md
  
  【理解】Active vs Docs 认知模型
    内容：Active = 大脑+草稿纸，Docs = 笔记本+档案袋
    → 建议更新 docs/planning/architecture.md
  
  是否沉淀？
  [a] 全部  [1,2] 选择  [n] 跳过  [e] 编辑

用户: a

Claude:
  ✓ 已追加到 docs/archive/decisions.md
  ✓ 已更新 docs/planning/constraints.md
  ✓ 已更新 docs/planning/architecture.md
```

## 实现计划

### Step 1: 最小原型（本周）
- [ ] 实现规则引擎（方案 A）
- [ ] 只检测决策信号（最重要）
- [ ] 输出建议但不自动写入
- [ ] 在 claude-devkit 自己的开发中测试

### Step 2: 迭代优化（下周）
- [ ] 观察误判率
- [ ] 调整规则阈值
- [ ] 添加约束和理解信号
- [ ] 考虑是否需要 LLM 辅助

### Step 3: 用户交互（第三周）
- [ ] 实现交互式确认
- [ ] 支持选择性沉淀
- [ ] 支持编辑后沉淀

## 边界情况

**误判处理**：
- 假阳性（不该沉淀的被建议）→ 用户可以跳过
- 假阴性（该沉淀的没检测到）→ 用户可以手动 /save（不带 --suggest）

**冲突处理**：
- 新决策与旧决策冲突 → 标记为"更新"而非"新增"
- 约束已存在 → 跳过或合并

**性能考虑**：
- 对话过长（>100 轮）→ 只分析最近 50 轮
- 检测超时（>5s）→ 降级为普通 /save

## 成功指标

**准确率**：
- 建议的内容 >80% 被用户接受
- 误判率 <20%

**覆盖率**：
- 重要决策 >90% 被检测到
- 用户很少需要手动补充

**用户体验**：
- 检测时间 <3s
- 建议数量 2-5 条（不过载）
- 交互流程 <3 步

_最后更新: 2026-04-24_
