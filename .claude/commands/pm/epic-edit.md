---
allowed-tools: Read, Write, LS
---

# 史诗任务编辑

创建后编辑史诗任务详情。

## 用法
```
/pm:epic-edit <epic_name>
```

## 指令

### 1. 读取当前史诗任务

读取 `.claude/epics/$ARGUMENTS/epic.md`：
- 解析 frontmatter
- 读取内容部分

### 2. 交互式编辑

询问用户要编辑什么：
- 名称/标题
- 描述/概述
- 架构决策
- 技术方法
- 依赖项
- 成功标准

### 3. 更新史诗任务文件

获取当前日期时间：`date -u +"%Y-%m-%dT%H:%M:%SZ"`

更新 epic.md：
- 保留除 `updated` 外的所有 frontmatter
- 将用户的编辑应用到内容
- 使用当前日期时间更新 `updated` 字段

### 4. 更新 GitHub 选项

如果史诗任务在 frontmatter 中有 GitHub URL：
询问：`"更新 GitHub 问题？(yes/no)"`

如果选择是：
```bash
gh issue edit {issue_number} --body-file .claude/epics/$ARGUMENTS/epic.md
```

### 5. 输出

```
✅ 已更新史诗任务: $ARGUMENTS
  更改部分: {已编辑的部分}
  
{如果已更新 GitHub}: GitHub 问题已更新 ✅

查看史诗任务: /pm:epic-show $ARGUMENTS
```

## 重要说明

保留 frontmatter 历史（创建时间、GitHub URL 等）。
编辑史诗任务时不要更改任务文件。
遵循 `/rules/frontmatter-operations.md`。