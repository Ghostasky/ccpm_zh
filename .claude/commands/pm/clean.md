---
allowed-tools: Bash, Read, Write, LS
---

# 清理

清理已完成的工作并归档旧的史诗任务。

## 用法
```
/pm:clean [--dry-run]
```

选项:
- `--dry-run` - 显示将要清理的内容但不执行

## 指令

### 1. 识别已完成的史诗任务

查找具有以下特征的史诗任务:
- frontmatter 中有 `status: completed`
- 所有任务已关闭
- 最后更新 > 30 天前

### 2. 识别陈旧工作

查找:
- 已关闭问题的进度文件
- 已完成工作的更新目录
- 孤立的任务文件（史诗任务已删除）
- 空目录

### 3. 显示清理计划

```
🧹 清理计划

待归档的已完成史诗任务:
  {epic_name} - {days} 天前完成
  {epic_name} - {days} 天前完成
  
待移除的陈旧进度:
  {count} 个已关闭问题的进度文件
  
空目录:
  {list_of_empty_dirs}
  
可回收空间: ~{size}KB

{If --dry-run}: 这是试运行。未做任何更改。
{Otherwise}: 继续清理？(yes/no)
```

### 4. 执行清理

如果用户确认:

**归档史诗任务:**
```bash
mkdir -p .claude/epics/.archived
mv .claude/epics/{completed_epic} .claude/epics/.archived/
```

**移除陈旧文件:**
- 删除 > 30 天的已关闭问题进度文件
- 移除空的更新目录
- 清理孤立文件

**创建归档日志:**
创建 `.claude/epics/.archived/archive-log.md`:
```markdown
# 归档日志

## {current_date}
- 已归档: {epic_name} ({date} 完成)
- 已移除: {count} 个陈旧进度文件
- 已清理: {count} 个空目录
```

### 5. 输出

```
✅ 清理完成

已归档:
  {count} 个已完成史诗任务
  
已移除:
  {count} 个陈旧文件
  {count} 个空目录
  
回收空间: {size}KB

系统已清理并整理。
```

## 重要说明

始终提供 --dry-run 来预览更改。
永不删除 PRD 或未完成的工作。
保留归档日志以记录历史。