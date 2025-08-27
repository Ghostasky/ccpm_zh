---
allowed-tools: Bash, Read, Write, LS
---

# 同步

本地与 GitHub 之间的完全双向同步。

## 用法
```
/pm:sync [epic_name]
```

如果提供了 epic_name，则仅同步该史诗任务。否则同步所有。

## 指令

### 1. 从 GitHub 拉取

获取所有问题的当前状态：
```bash
# 获取所有史诗任务和任务问题
gh issue list --label "epic" --limit 1000 --json number,title,state,body,labels,updatedAt
gh issue list --label "task" --limit 1000 --json number,title,state,body,labels,updatedAt
```

### 2. 从 GitHub 更新本地

对于每个 GitHub 问题：
- 通过问题编号找到对应的本地文件
- 比较状态：
  - 如果 GitHub 状态更新 (updatedAt > local updated)，则更新本地
  - 如果 GitHub 已关闭但本地开放，则关闭本地
  - 如果 GitHub 重新打开但本地已关闭，则重新打开本地
- 更新 frontmatter 以匹配 GitHub 状态

### 3. 将本地推送到 GitHub

对于每个本地任务/史诗任务：
- 如果有 GitHub URL 但未找到 GitHub 问题，则已被删除 - 将本地标记为已归档
- 如果无 GitHub URL，则创建新问题（类似 epic-sync）
- 如果本地更新 > GitHub updatedAt，则推送更改：
  ```bash
  gh issue edit {number} --body-file {local_file}
  ```

### 4. 处理冲突

如果双方都已更改（本地和 GitHub 自上次同步以来都已更新）：
- 显示两个版本
- 询问用户："本地和 GitHub 都已更改。保留：(local/github/merge)？"
- 应用用户的选择

### 5. 更新同步时间戳

更新所有已同步文件的 last_sync 时间戳。

### 6. 输出

```
🔄 同步完成

从 GitHub 拉取:
  已更新: {count} 个文件
  已关闭: {count} 个问题
  
推送到 GitHub:
  已更新: {count} 个问题
  已创建: {count} 个新问题
  
已解决冲突: {count}

状态:
  ✅ 所有文件已同步
  {或列出任何同步失败}
```

## 重要说明

遵循 `/rules/github-operations.md` 进行 GitHub 命令。
遵循 `/rules/frontmatter-operations.md` 进行本地更新。
同步前始终备份以防出现问题。