---
allowed-tools: Read, LS
---

# Epic 一次性处理

将 Epic 分解为任务并同步到 GitHub 的一键操作。

## 用法
```
/pm:epic-oneshot <feature_name>
```

## 指令

### 1. 验证先决条件

检查 Epic 是否存在且未被处理：
```bash
# Epic 必须存在
test -f .claude/epics/$ARGUMENTS/epic.md || echo "❌ Epic 未找到。运行: /pm:prd-parse $ARGUMENTS"

# 检查现有任务
if ls .claude/epics/$ARGUMENTS/[0-9]*.md 2>/dev/null | grep -q .; then
  echo "⚠️ 任务已存在。这将创建重复项。"
  echo "删除现有任务或使用 /pm:epic-sync 替代。"
  exit 1
fi

# 检查是否已同步
if grep -q "github:" .claude/epics/$ARGUMENTS/epic.md; then
  echo "⚠️ Epic 已同步到 GitHub。"
  echo "使用 /pm:epic-sync 进行更新。"
  exit 1
fi
```

### 2. 执行分解

直接运行分解命令：
```
运行中: /pm:epic-decompose $ARGUMENTS
```

这将：
- 读取 epic
- 创建任务文件（如适用，使用并行代理）
- 使用任务摘要更新 epic

### 3. 执行同步

紧接着执行同步：
```
运行中: /pm:epic-sync $ARGUMENTS
```

这将：
- 在 GitHub 上创建 epic 问题
- 创建子问题（如适用，使用并行代理）
- 将任务文件重命名为问题 ID
- 创建工作树

### 4. 输出

```
🚀 Epic 一次性处理完成: $ARGUMENTS

步骤 1: 分解 ✓
  - 创建的任务: {count}
  
步骤 2: GitHub 同步 ✓
  - Epic: #{number}
  - 创建的子问题: {count}
  - 工作树: ../epic-$ARGUMENTS

准备开发!
  开始工作: /pm:epic-start $ARGUMENTS
  或单个任务: /pm:issue-start {task_number}
```

## 重要说明

这只是一个便利的包装器，运行：
1. `/pm:epic-decompose` 
2. `/pm:epic-sync`

两个命令都处理自己的错误检查、并行执行和验证。此命令只是按顺序编排它们。

当您确信 epic 已准备就绪并希望从 epic 一步到位到 GitHub 问题时，请使用此命令。