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
| 对话级 | `.claude/context.md` | 当前对话的目标、计划、决策 | `/ctx` |
| 项目级 | `.claude/snapshots/<date>.md` | 项目状态快照（中断恢复） | `/snapshot` |
| 项目级 | `.claude/decisions/<slug>.md` | 结构化决策记录（知识沉淀） | `/distill` |
| 项目级 | `.claude/project.yaml` | 项目元信息（名称、用途、阶段） | `/init` |
| 全局级 | `~/.claude/knowledge/` | 跨项目可复用知识 | Phase 4 |

## 安装

```bash
cd context-kit
./install.sh
```

安装后会在 `~/.claude/` 创建符号链接：
- `agents/{context,snapshot,recap,init,distill}.md` - 5 个 agent
- `commands/{ctx,snapshot,recap,init,distill}.md` - 5 个命令
- `scripts/` - trace hook 脚本

## 快速上手

**新项目开始时**：
```bash
/init              # 初始化项目知识结构
/ctx update        # 记录当前目标和计划
```

**开发过程中**：
```bash
/ctx check         # 检查当前进度，防止偏离目标
/ctx update        # 完成阶段性工作后更新状态
```

**会话结束前**：
```bash
/snapshot          # 保存项目快照，方便下次恢复
```

**新会话开始时**：
```bash
/recap             # 快速了解上次做到哪了
```

**定期整理**：
```bash
/distill           # 从快照中提炼关键决策到 decisions/
```

## 可用命令

| 命令 | 功能 | 使用场景 |
|------|------|---------|
| `/ctx` | 对话级上下文管理 | 记录目标、更新进度、防止偏离 |
| `/init` | 初始化项目结构 | 新项目开始时运行一次 |
| `/snapshot` | 保存项目快照 | 会话结束前保存状态 |
| `/recap` | 跨会话恢复 | 新会话开始时快速恢复 |
| `/distill` | 提炼决策记录 | 定期整理关键决策 |

## 命令详解

### `/ctx` — 对话级上下文管理

维护 `.claude/context.md`（≤60 行，六段式结构）。

```
/ctx update    # 从对话历史提取信息，更新 context.md
/ctx check     # 报告当前 Goal 和进度
/ctx reset     # 清空 context.md（需确认）
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

### `/init` — 初始化项目知识结构

创建 `.claude/project.yaml` 和 `.claude/decisions/` 目录。

```
/init              # 在项目开始时初始化知识结构
```

**创建的文件**：
- `.claude/project.yaml` — 项目名称、用途、当前阶段（从 git remote 和 README 自动推断）
- `.claude/decisions/index.md` — 决策索引

### `/distill` — 从 snapshots 提炼决策

读取 snapshots 和 context.md，识别关键决策，写入结构化记录。

```
/distill           # 从最近 3 个 snapshots 提炼决策
```

**决策格式**（`.claude/decisions/<slug>.md`）：
```markdown
# Hook 协议改为 stdin JSON

**Date**: 2026-04-19
**Scope**: trace hook

## Choice
从环境变量改为 stdin JSON 协议。

## Why
- 环境变量不符合 Claude Code 实际协议
- stdin JSON 是官方协议，devkit 已验证可行

## Rejected
- 保持环境变量：生产环境无法工作

## Impact
- 修复了 trace hook 的生产 bug
- 需要重写 test.sh 的 hook 测试
```

**数据流向**：trace → `/snapshot` 消费 → `/distill` 提炼 → decisions/

## 自动追踪

trace hook 自动记录所有 Edit/Write/Bash/TaskUpdate 到 `.claude/trace/<session>.jsonl`：

```json
{"ts":"2026-04-19T10:30:00Z","tool":"Edit","file":"src/main.ts"}
{"ts":"2026-04-19T10:31:15Z","tool":"Bash","cmd":"npm test","exit":1,"err":"TypeError: Cannot read property"}
{"ts":"2026-04-19T10:32:00Z","tool":"TaskUpdate","task":"task-1","status":"completed"}
```

**数据流向**：trace → `/snapshot` 消费 → `/distill` 提炼 → `/recap` 呈现

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
| Agent 数量 | 6 个 | 5 个 |
| Hook 复杂度 | 84 行（多分支+副作用） | 55 行（纯记录） |
| 自动化程度 | 高（auto-checkpoint、auto-promote） | 低（手动触发） |
| 提示词总量 | ~550 行 | ~430 行 |
| 核心文件 | context.md（自由格式，≤120 行） | context.md（固定格式，≤60 行） |
| 决策记录 | decisions/ + assets/ + confidence 1-5 | decisions/（无 assets） |
| 跨会话恢复 | 读 checkpoint + task + decisions | 读 snapshot + context + git |

## 路线图

- [x] **Phase 1**: 对话级上下文（trace hook + context agent）
- [x] **Phase 2**: 项目级快照（snapshot agent + recap agent）
- [x] **Phase 3**: 项目级资产（init agent + distill agent + decisions/）
- [ ] **Phase 4**: 全局级知识（extract agent，跨项目复用）

## License

MIT
