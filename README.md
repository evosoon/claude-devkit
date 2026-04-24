# claude-devkit

轻量级 Claude Code 上下文管理工具 — 让 AI 协作产生的隐性知识不再流失。

## 愿景

**从对话到资产**：将 AI 协作中产生的决策、约束、理解沉淀为 git 可追踪的项目资产，让每次对话的价值可以跨会话复利。

**三个核心场景**：
1. **多任务切换**：在项目 A/B/C 间切换时，快速恢复上下文
2. **中断恢复**：几天后回到项目，记得"为什么这样做"
3. **知识复利**：决策和约束沉淀后，避免重复踩坑

## 解决什么问题

开发对话中做了大量决策（"试了 A 不行因为 X，改用 B"），但会话结束后这些信息随之消散。`--continue` 能恢复会话，memory 能记住偏好，但**决策的 why 和 tradeoff** 没有被系统性捕获。

## 两个命令

| 命令 | 时机 | 做什么 |
|------|------|--------|
| `/save` | 会话结束前 | 回顾对话，提取状态和决策，写入项目文件 |
| `/recap` | 新会话开始 | 读取状态 + 决策 + git，输出恢复简报 |

## 数据流

```
对话中的隐性决策
    ↓  /save
.claude/active/state.md              ← 覆写，当前工作状态
.claude/docs/archive/decisions.md    ← 追加，历史决策记录
.claude/docs/planning/constraints.md ← 更新，当前约束
    ↓  git commit → 跨设备同步
    ↓  /recap
恢复简报 → 继续工作
```

## 核心概念

**Active vs Docs**（工作区 vs 文档区）：

```
Active（大脑+草稿纸）          Docs（笔记本+档案袋）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
易变、会话级、可丢弃           稳定、项目级、持久化
state.md（当前状态）           planning/（活跃文档）
                              archive/（历史记录）
```

**Planning vs Archive**（笔记本 vs 档案袋）：

| 维度 | Planning | Archive |
|------|----------|---------|
| 时态 | 现在/未来 | 过去 |
| 操作 | 更新/覆写 | 追加/不变 |
| 内容 | 路线图、约束、架构理解 | 决策日志、探索记录 |

## 安装

```bash
git clone <repo> && cd claude-devkit
./install.sh
```

在 `~/.claude/commands/` 创建符号链接，所有项目可用。

## 使用

**会话结束前**：
```
/save
```
Claude 回顾对话，自动提取状态和决策写入 `.claude/active/` 和 `.claude/docs/`。

**智能建议**（自动启用）：
- 检测对话中的决策信号（"选择 X 而非 Y"）
- 检测约束信号（"不能用 X 因为 Y"）
- 检测理解信号（"原来 X 是因为 Y"）
- 建议值得沉淀的内容，等待确认后写入
- 如不需要建议，对话中说"只保存 state"即可跳过

**新会话开始**：
```
/recap
```
Claude 读取上次状态 + 文档 + git 历史，输出中文简报。

**记得 git 跟踪**：
```bash
git add .claude/active/ .claude/docs/
```

> ⚠️ **重要**：最大的风险是忘记 `/save`。建议启用自动提醒（见下文）。

## 可选：自动提醒

人类会忘记运行 `/save`，导致决策依然流失。可以启用自动提醒：

```bash
./setup-reminder.sh
```

**工作原理**：
- 安装一个 Claude Code `Stop` hook（每次 Claude 回复后触发）
- 检测 `.claude/active/state.md` 是否缺失或超过 30 分钟未更新
- 显示非侵入式提醒："💡 提示：会话结束前记得运行 /save 保存上下文"

**卸载**：
```bash
rm ~/.claude/hooks/remind-save.sh
# 并从 ~/.claude/settings.json 中移除对应的 hook 配置
```

参考配置见 `.claude/settings.json.example`。

## 卸载

```bash
./uninstall.sh
```

## 测试

```bash
./test.sh
```

## License

MIT
