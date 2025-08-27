---
allowed-tools: Bash, Read, LS
---

# 问题状态

检查问题状态（开放/已关闭）和当前状态。

## 用法
```
/pm:issue-status <issue_number>
```

## 指令

您正在检查 GitHub 问题的当前状态并为以下问题提供快速状态报告：**Issue #$ARGUMENTS**

### 1. 获取问题状态
使用 GitHub CLI 获取当前状态：
```bash
gh issue view #$ARGUMENTS --json state,title,labels,assignees,updatedAt
```

### 2. 状态显示
显示简洁的状态信息：
```
🎫 Issue #$ARGUMENTS: {标题}
   
📊 状态: {开放/已关闭}
   最后更新: {时间戳}
   负责人: {负责人或"未分配"}
   
🏷️ 标签: {标签1}, {标签2}, {标签3}
```

### 3. 史诗任务上下文
如果问题是史诗任务的一部分：
```
📚 史诗任务上下文:
   史诗任务: {史诗任务名称}
   史诗任务进度: {已完成任务}/{总任务} 任务完成
   此任务: {任务位置} of {总任务}
```

### 4. 本地同步状态
检查本地文件是否同步：
```
💾 本地同步:
   本地文件: {存在/缺失}
   最后本地更新: {时间戳}
   同步状态: {已同步/需要同步/本地领先/远程领先}
```

### 5. 快速状态指示器
使用清晰的视觉指示器：
- 🟢 开放且就绪
- 🟡 开放但有阻碍  
- 🔴 开放且逾期
- ✅ 已关闭且完成
- ❌ 已关闭但未完成

### 6. 可操作的下一步
根据状态，建议操作：
```
🚀 建议操作:
   - 开始工作: /pm:issue-start $ARGUMENTS
   - 同步更新: /pm:issue-sync $ARGUMENTS
   - 关闭问题: gh issue close #$ARGUMENTS
   - 重新打开问题: gh issue reopen #$ARGUMENTS
```

### 7. 批量状态
如果检查多个问题，支持逗号分隔列表：
```
/pm:issue-status 123,124,125
```

保持输出简洁但信息丰富，非常适合在开发 Issue #$ARGUMENTS 期间快速状态检查。