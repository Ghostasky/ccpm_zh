# GitHub 操作规则

所有命令中 GitHub CLI 操作的标准模式。

## 认证

**不要预先检查认证。** 只需运行命令并处理失败：

```bash
gh {command} || echo "❌ GitHub CLI 失败。运行: gh auth login"
```

## 常见操作

### 获取问题详情
```bash
gh issue view {number} --json state,title,labels,body
```

### 创建问题
```bash
gh issue create --title "{title}" --body-file {file} --label "{labels}"
```

### 更新问题
```bash
gh issue edit {number} --add-label "{label}" --add-assignee @me
```

### 添加评论
```bash
gh issue comment {number} --body-file {file}
```

## 错误处理

如果任何 gh 命令失败：
1. 显示清晰错误："❌ GitHub 操作失败: {command}"
2. 建议修复："运行: gh auth login" 或检查问题编号
3. 不要自动重试

## 重要说明

- 信任 gh CLI 已安装并已认证
- 解析时使用 --json 以获得结构化输出
- 保持操作原子性 - 每个操作一个 gh 命令
- 不要预先检查速率限制