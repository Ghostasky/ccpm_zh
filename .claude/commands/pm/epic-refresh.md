---
allowed-tools: Read, Write, LS
---

# 史诗任务刷新

根据任务状态更新史诗任务进度。

## 用法
```
/pm:epic-refresh <epic_name>
```

## 指令

### 1. 统计任务状态

扫描 `.claude/epics/$ARGUMENTS/` 中的所有任务文件：
- 统计总任务数
- 统计有 `status: closed` 的任务数
- 统计有 `status: open` 的任务数
- 统计进行中的任务数

### 2. 计算进度

```
progress = (已关闭任务 / 总任务) * 100
```

四舍五入到最接近的整数。

### 3. 更新 GitHub 任务列表

如果史诗任务有 GitHub 问题，则同步任务复选框：

```bash
# 从 epic.md frontmatter 获取史诗任务问题编号
epic_issue={从 github 字段提取}

if [ ! -z "$epic_issue" ]; then
  # 获取当前史诗任务正文
  gh issue view $epic_issue --json body -q .body > /tmp/epic-body.md
  
  # 对于每个任务，检查其状态并更新复选框
  for task_file in .claude/epics/$ARGUMENTS/[0-9]*.md; do
    task_issue=$(grep 'github:' $task_file | grep -oE '[0-9]+$')
    task_status=$(grep 'status:' $task_file | cut -d: -f2 | tr -d ' ')
    
    if [ "$task_status" = "closed" ]; then
      # 标记为已勾选
      sed -i "s/- \\[ \\] #$task_issue/- [x] #$task_issue/" /tmp/epic-body.md
    else
      # 确保未勾选（以防手动勾选）
      sed -i "s/- \\[x\\] #$task_issue/- [ ] #$task_issue/" /tmp/epic-body.md
    fi
  done
  
  # 更新史诗任务问题
  gh issue edit $epic_issue --body-file /tmp/epic-body.md
fi
```

### 4. 确定史诗任务状态

- 如果进度 = 0% 且无工作开始：`backlog`
- 如果进度 > 0% 且 < 100%：`in-progress`
- 如果进度 = 100%：`completed`

### 5. 更新史诗任务

获取当前日期时间：`date -u +"%Y-%m-%dT%H:%M:%SZ"`

更新 epic.md frontmatter：
```yaml
status: {计算的状态}
progress: {计算的进度}%
updated: {current_datetime}
```

### 6. 输出

```
🔄 史诗任务已刷新: $ARGUMENTS

任务:
  已关闭: {已关闭数量}
  开放: {开放数量}
  总计: {总数量}
  
进度: {旧进度}% → {新进度}%
状态: {旧状态} → {新状态}
GitHub: 任务列表已更新 ✓

{如果完成}: 运行 /pm:epic-close $ARGUMENTS 关闭史诗任务
{如果进行中}: 运行 /pm:next 查看优先任务
```

## 重要说明

这在手动任务编辑或 GitHub 同步后很有用。
不要修改任务文件，仅更新史诗任务状态。
保留所有其他 frontmatter 字段。