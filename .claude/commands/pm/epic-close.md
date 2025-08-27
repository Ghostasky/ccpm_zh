---
allowed-tools: Bash, Read, Write, LS
---

# 史诗任务关闭

当所有任务完成时将史诗任务标记为完成。

## 用法
```
/pm:epic-close <epic_name>
```

## 指令

### 1. 验证所有任务完成

检查 `.claude/epics/$ARGUMENTS/` 中的所有任务文件：
- 验证所有文件在 frontmatter 中都有 `status: closed`
- 如果发现任何开放任务：`"❌ 无法关闭史诗任务。仍有开放任务: {list}"`

### 2. 更新史诗任务状态

获取当前日期时间：`date -u +"%Y-%m-%dT%H:%M:%SZ"`

更新 epic.md frontmatter：
```yaml
status: completed
progress: 100%
updated: {current_datetime}
completed: {current_datetime}
```

### 3. 更新 PRD 状态

如果史诗任务引用了 PRD，则将其状态更新为"complete"。

### 4. 在 GitHub 上关闭史诗任务

如果史诗任务有 GitHub 问题：
```bash
gh issue close {epic_issue_number} --comment "✅ 史诗任务完成 - 所有任务已完成"
```

### 5. 归档选项

询问用户：`"归档已完成的史诗任务？(yes/no)"`

如果选择是：
- 将史诗任务目录移动到 `.claude/epics/.archived/{epic_name}/`
- 创建包含完成日期的归档摘要

### 6. 输出

```
✅ 史诗任务已关闭: $ARGUMENTS
  已完成任务: {count}
  持续时间: {从创建到完成的天数}
  
{如果已归档}: 已归档到 .claude/epics/.archived/

下一个史诗任务: 运行 /pm:next 查看优先工作
```

## 重要说明

仅关闭所有任务都已完成的史诗任务。
归档时保留所有数据。
更新相关的 PRD 状态。