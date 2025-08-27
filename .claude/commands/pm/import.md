---
allowed-tools: Bash, Read, Write, LS
---

# 导入

将现有的 GitHub 问题导入到 PM 系统中。

## 用法
```
/pm:import [--epic <epic_name>] [--label <label>]
```

选项:
- `--epic` - 导入到特定史诗任务
- `--label` - 仅导入带有特定标签的问题
- 无参数 - 导入所有未跟踪的问题

## 指令

### 1. 获取 GitHub 问题

```bash
# 根据过滤器获取问题
if [[ "$ARGUMENTS" == *"--label"* ]]; then
  gh issue list --label "{label}" --limit 1000 --json number,title,body,state,labels,createdAt,updatedAt
else
  gh issue list --limit 1000 --json number,title,body,state,labels,createdAt,updatedAt
fi
```

### 2. 识别未跟踪的问题

对于每个 GitHub 问题：
- 在本地文件中搜索匹配的 github URL
- 如果未找到，则为未跟踪需要导入

### 3. 分类问题

基于标签：
- 带有 "epic" 标签的问题 → 创建史诗任务结构
- 带有 "task" 标签的问题 → 在适当的史诗任务中创建任务
- 带有 "epic:{name}" 标签的问题 → 分配给该史诗任务
- 无 PM 标签 → 询问用户或在 "imported" 史诗任务中创建

### 4. 创建本地结构

对于每个要导入的问题：

**如果是史诗任务：**
```bash
mkdir -p .claude/epics/{epic_name}
# 使用 GitHub 内容和 frontmatter 创建 epic.md
```

**如果是任务：**
```bash
# 查找下一个可用编号 (001.md, 002.md, 等)
# 使用 GitHub 内容创建任务文件
```

设置 frontmatter：
```yaml
name: {issue_title}
status: {open|closed based on GitHub}
created: {GitHub createdAt}
updated: {GitHub updatedAt}
github: https://github.com/{org}/{repo}/issues/{number}
imported: true
```

### 5. 输出

```
📥 导入完成

已导入:
  史诗任务: {count}
  任务: {count}
  
创建的结构:
  {epic_1}/
    - {count} 个任务
  {epic_2}/
    - {count} 个任务
    
已跳过 (已跟踪): {count}

下一步:
  运行 /pm:status 查看导入的工作
  运行 /pm:sync 确保完全同步
```

## 重要说明

在 frontmatter 中保留所有 GitHub 元数据。
用 `imported: true` 标志标记导入的文件。
不要覆盖现有的本地文件。