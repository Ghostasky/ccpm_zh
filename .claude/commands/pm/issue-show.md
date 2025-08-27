---
allowed-tools: Bash, Read, LS
---

# 问题显示

显示问题和子问题的详细信息。

## 用法
```
/pm:issue-show <issue_number>
```

## 指令

您正在为以下问题显示全面信息：**Issue #$ARGUMENTS**

### 1. 获取问题数据
- 使用 `gh issue view #$ARGUMENTS` 获取 GitHub 问题详情
- 查找本地任务文件：首先检查 `.claude/epics/*/$ARGUMENTS.md` (新命名)
- 如果未找到，搜索 frontmatter 中有 `github:.*issues/$ARGUMENTS` 的文件 (旧命名)
- 检查相关问题和子任务

### 2. 问题概览
显示问题头部：
```
🎫 Issue #$ARGUMENTS: {问题标题}
   状态: {开放/已关闭}
   标签: {标签}
   负责人: {负责人}
   创建时间: {创建日期}
   更新时间: {最后更新}
   
📝 描述:
{问题描述}
```

### 3. 本地文件映射
如果存在本地任务文件：
```
📁 本地文件:
   任务文件: .claude/epics/{史诗任务名称}/{任务文件}
   更新: .claude/epics/{史诗任务名称}/updates/$ARGUMENTS/
   最后本地更新: {时间戳}
```

### 4. 子问题和依赖项
显示相关问题：
```
🔗 相关问题:
   父史诗任务: #{史诗任务问题编号}
   依赖项: #{依赖1}, #{依赖2}
   阻塞: #{阻塞1}, #{阻塞2}
   子任务: #{子任务1}, #{子任务2}
```

### 5. 最近活动
显示最近评论和更新：
```
💬 最近活动:
   {时间戳} - {作者}: {评论预览}
   {时间戳} - {作者}: {评论预览}
   
   查看完整线程: gh issue view #$ARGUMENTS --comments
```

### 6. 进度跟踪
如果存在任务文件，显示进度：
```
✅ 验收标准:
   ✅ 标准 1 (已完成)
   🔄 标准 2 (进行中)
   ⏸️ 标准 3 (被阻塞)
   □ 标准 4 (未开始)
```

### 7. 快速操作
```
🚀 快速操作:
   开始工作: /pm:issue-start $ARGUMENTS
   同步更新: /pm:issue-sync $ARGUMENTS
   添加评论: gh issue comment #$ARGUMENTS --body "您的评论"
   在浏览器中查看: gh issue view #$ARGUMENTS --web
```

### 8. 错误处理
- 优雅处理无效问题编号
- 检查网络/认证问题
- 提供有用的错误消息和替代方案

提供全面的问题信息，帮助开发者理解 Issue #$ARGUMENTS 的上下文和当前状态。