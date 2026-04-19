# context-kit

轻量级 Claude Code 上下文管理工具，帮助你在开发过程中保持目标清晰、快速恢复中断。

## 核心理念

- **对话级优先** - 先解决"防止偏离目标"，再考虑中断恢复和知识复利
- **最小自动化** - hooks 只做轻量追踪，其余手动触发
- **单一职责** - 每个工具只做一件事，边界清晰
- **文件即接口** - 固定格式的 context.md，工具可预测地读写

## 三级知识体系

| 级别 | 文件位置 | 用途 | 更新方式 |
|------|---------|------|---------|
| 对话级 | `.claude/context.md` | 当前对话的目标、计划、决策 | `/context` |
| 项目级 | `.claude/snapshots/<date>.md` | 项目状态快照（中断恢复） | `/snapshot` |
| 全局级 | `~/.claude/knowledge/` | 跨项目可复用知识 | extract agent (Phase 3) |

## 安装

```bash
cd context-kit
./install.sh
```

安装后会在 `~/.claude/` 创建符号链接：
- `agents/{context,snapshot,recap}.md` - 3 个 agent
- `commands/{context,snapshot,recap}.md` - 3 个硬派发命令
- `scripts/` - trace hook 脚本

## 命令

### `/context` — 对话级上下文管理

维护 `.claude/context.md`（≤60 行，六段式结构）。

```
/context update    # 从对话历史提取信息，更新 context.md
/context check     # 报告当前 Goal 和进度
/context reset     # 清空 context.md（需确认）
```

**context.md 格式**：

```markdown
# Context

## Goal
实现 context-kit v2 核心功能

## Plan
- [x] 修复 trace hook
- [x] 创建 snapshot agent
- [ ] 编写测试

## Changes
- .claude/scripts/hook-post-tool.sh (重写)
- agents/snapshot.md (新增)

## Blockers
（无）

## Decisions
- Hook 协议从 env 变量改为 stdin JSON
- context.md 固定格式（≤60 行），便于工具解析

## Next
运行测试验证功能
```

### `/snapshot` — 项目级快照

读取 trace + git + context，生成 `.claude/snapshots/<date>.md`。

```
/snapshot          # 保存当前项目状态快照
```

**适用场景**：结束会话前保存状态，方便下次恢复。

**快照内容**：
- 目标（from context.md）
- 变更文件列表（from trace，带 Edit/Write 计数）
- Git 状态（分支、最近提交、未提交文件）
- 失败命令及错误信息
- 计划进度 + 下一步

### `/recap` — 跨会话恢复

读取 snapshot + context + git，输出 ≤25 行中文简报。

```
/recap             # 快速回到上次工作状态
```

**适用场景**：新会话开始时，快速了解"上次做到哪了"。

**降级策略**：
- 有 snapshot → 使用 snapshot（最丰富）
- 无 snapshot → 使用 context.md + git
- 无 context.md → 只用 git + 提示运行 `/context update`

## 自动追踪

trace hook 自动记录所有 Edit/Write/Bash/TaskUpdate 到 `.claude/trace/<session>.jsonl`：

```json
{"ts":"2026-04-19T10:30:00Z","tool":"Edit","file":"src/main.ts"}
{"ts":"2026-04-19T10:31:15Z","tool":"Bash","cmd":"npm test","exit":1,"err":"TypeError: Cannot read property"}
{"ts":"2026-04-19T10:32:00Z","tool":"TaskUpdate","task":"task-1","status":"completed"}
```

**数据流向**：trace → `/snapshot` 消费 → `/recap` 呈现

## 配置

项目需要 `.claude/settings.local.json` 来启用 trace hook：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|Bash|TaskUpdate",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/scripts/hook-post-tool.sh"
          }
        ]
      }
    ]
  }
}
```

## 测试

```bash
./test.sh
```

测试覆盖（24 项）：
- install/uninstall 符号链接管理（11 项）
- trace hook stdin JSON 协议（13 项）：Edit/Write/Bash（成功+失败+stderr）/TaskUpdate/追加/分 session/size guard

## 卸载

```bash
./uninstall.sh
```

会移除所有符号链接并恢复备份文件。

## 与 devkit 的对比

| 维度 | devkit | context-kit |
|------|--------|-------------|
| Agent 数量 | 6 个 | 3 个 |
| Hook 复杂度 | 84 行（多分支+副作用） | 55 行（纯记录） |
| 自动化程度 | 高（auto-checkpoint、auto-promote） | 低（手动触发） |
| 提示词总量 | ~550 行 | ~250 行 |
| 核心文件 | context.md（自由格式，≤120 行） | context.md（固定格式，≤60 行） |
| 跨会话恢复 | 读 checkpoint + task + decisions | 读 snapshot + context + git |

## 路线图

- [x] **Phase 1**: 对话级上下文（trace hook + context agent）
- [x] **Phase 2**: 项目级快照（snapshot agent + recap agent）
- [ ] **Phase 3**: 全局级知识（extract agent，知识复利）

## License

MIT
