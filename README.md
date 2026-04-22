# claude-devkit

锚定对话中流失的隐性决策，沉淀为 git 可追踪的项目资产。

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
.claude/context/state.md     ← 覆写，永远是最新状态
.claude/context/decisions.md ← 追加，只增不删
    ↓  git commit → 跨设备同步
    ↓  /recap
恢复简报 → 继续工作
```

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
Claude 回顾对话，自动提取状态和决策写入 `.claude/context/`。

**新会话开始**：
```
/recap
```
Claude 读取上次状态 + 决策记录 + git 历史，输出中文简报。

**记得 git 跟踪**：
```bash
git add .claude/context/
```

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
