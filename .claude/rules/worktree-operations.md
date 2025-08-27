# Worktree 操作

Git worktree 通过为同一仓库提供多个工作目录来实现并行开发。

## 创建 Worktree

始终从干净的主分支创建 worktree：
```bash
# 确保主分支是最新的
git checkout main
git pull origin main

# 为 epic 创建 worktree
git worktree add ../epic-{name} -b epic/{name}
```

worktree 将被创建为同级目录以保持清晰的分离。

## 在 Worktree 中工作

### 代理提交
- 代理直接提交到 worktree
- 使用小而专注的提交
- 提交消息格式：`Issue #{number}: {description}`
- 示例：`Issue #1234: 添加用户认证模式`

### 文件操作
```bash
# 工作目录是 worktree
cd ../epic-{name}

# 正常的 git 操作有效
git add {files}
git commit -m "Issue #{number}: {change}"

# 查看 worktree 状态
git status
```

## 在同一 Worktree 中并行工作

如果多个代理处理不同文件，可以在同一 worktree 中工作：
```bash
# 代理 A 处理 API
git add src/api/*
git commit -m "Issue #1234: 添加用户端点"

# 代理 B 处理 UI (无冲突!)
git add src/ui/*
git commit -m "Issue #1235: 添加仪表板组件"
```

## 合并 Worktree

当 epic 完成时，合并回主分支：
```bash
# 从主仓库 (不是 worktree)
cd {main-repo}
git checkout main
git pull origin main

# 合并 epic 分支
git merge epic/{name}

# 如果成功，则清理
git worktree remove ../epic-{name}
git branch -d epic/{name}
```

## 处理冲突

如果发生合并冲突：
```bash
# 将显示冲突
git status

# 人工解决冲突
# 然后继续合并
git add {resolved-files}
git commit
```

## Worktree 管理

### 列出活动 Worktree
```bash
git worktree list
```

### 删除过时 Worktree
```bash
# 如果 worktree 目录已被删除
git worktree prune

# 强制删除 worktree
git worktree remove --force ../epic-{name}
```

### 检查 Worktree 状态
```bash
# 从主仓库
cd ../epic-{name} && git status && cd -
```

## 最佳实践

1. **每个 epic 一个 worktree** - 不是每个问题一个 worktree
2. **创建前清理** - 始终从更新的主分支开始
3. **频繁提交** - 小提交更容易合并
4. **合并后删除** - 不要留下过时的 worktree
5. **使用描述性分支** - `epic/feature-name` 而不是 `feature`

## 常见问题

### Worktree 已存在
```bash
# 首先删除旧 worktree
git worktree remove ../epic-{name}
# 然后创建新 worktree
```

### 分支已存在
```bash
# 删除旧分支
git branch -D epic/{name}
# 或使用现有分支
git worktree add ../epic-{name} epic/{name}
```

### 无法删除 Worktree
```bash
# 强制删除
git worktree remove --force ../epic-{name}
# 清理引用
git worktree prune
```