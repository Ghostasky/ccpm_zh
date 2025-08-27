# Frontmatter 操作规则

在 markdown 文件中处理 YAML frontmatter 的标准模式。

## 读取 Frontmatter

从任何 markdown 文件中提取 frontmatter：
1. 查找文件开头的 `---` 标记之间的内容
2. 解析为 YAML
3. 如果无效或缺失，使用合理的默认值

## 更新 Frontmatter

更新现有文件时：
1. 保留所有现有字段
2. 仅更新指定字段
3. 始终使用当前日期时间更新 `updated` 字段（参见 `/rules/datetime.md`）

## 标准字段

### 所有文件
```yaml
---
name: {标识符}
created: {ISO 日期时间}      # 创建后永不更改
updated: {ISO 日期时间}      # 任何修改时更新
---
```

### 状态值
- PRD: `backlog`, `in-progress`, `complete`
- Epic: `backlog`, `in-progress`, `completed`  
- 任务: `open`, `in-progress`, `closed`

### 进度跟踪
```yaml
progress: {0-100}%           # 用于 epic
completion: {0-100}%         # 用于进度文件
```

## 创建新文件

创建 markdown 文件时始终包含 frontmatter：
```yaml
---
name: {来自参数或上下文}
status: {初始状态}
created: {当前日期时间}
updated: {当前日期时间}
---
```

## 重要说明

- 创建后永不修改 `created` 字段
- 始终使用来自系统的实际日期时间（参见 `/rules/datetime.md`）
- 尝试解析前验证 frontmatter 是否存在
- 在所有文件中使用一致的字段名称