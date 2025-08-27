---
allowed-tools: Bash, Read, Write, LS
---

# 问题重新打开

重新打开已关闭的问题。

## 用法
```
/pm:issue-reopen <issue_number> [reason]
```

## 指令

### 1. 查找本地任务文件

搜索 frontmatter 中有 `github:.*issues/$ARGUMENTS` 的任务文件。
如果未找到：`"❌ 问题 #$ARGUMENTS 无本地任务"`

### 2. 更新本地状态

获取当前日期时间：`date -u +"%Y-%m-%dT%H:%M:%SZ"`

更新任务文件 frontmatter：
```yaml
status: open
updated: {current_datetime}
```

### 3. 重置进度

如果进度文件存在：
- 保留原始开始日期
- 将完成度重置为之前的值或 0%
- 添加关于重新打开原因的说明

### 4. 在 GitHub 上重新打开

```bash
# 带评论重新打开
echo "🔄 重新打开问题

原因: $ARGUMENTS

---
重新打开于: {timestamp}" | gh issue comment $ARGUMENTS --body-file -

# 重新打开问题
gh issue reopen $ARGUMENTS
```

### 5. 更新史诗任务进度

重新计算史诗任务进度，此任务现在再次开放。

### 6. 输出

```
🔄 已重新打开问题 #$ARGUMENTS
  原因: {如果提供则显示原因}
  史诗任务进度: {更新后的进度}%
  
开始工作: /pm:issue-start $ARGUMENTS
```

## 重要说明

在进度文件中保留工作历史。
不要删除之前的进度，只需重置状态。