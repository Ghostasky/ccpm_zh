---
allowed-tools: Bash, Read, Write, LS, Task
---

# Epic 同步

将 epic 和任务推送到 GitHub 作为问题。

## 用法
```
/pm:epic-sync <feature_name>
```

## 快速检查

```bash
# 验证 epic 是否存在
test -f .claude/epics/$ARGUMENTS/epic.md || echo "❌ Epic 未找到。运行: /pm:prd-parse $ARGUMENTS"

# 统计任务文件
ls .claude/epics/$ARGUMENTS/*.md 2>/dev/null | grep -v epic.md | wc -l
```

如果未找到任务："❌ 没有要同步的任务。运行: /pm:epic-decompose $ARGUMENTS"

## 指令

### 1. 创建 Epic 问题

剥离 frontmatter 并准备 GitHub 问题正文：
```bash
# 提取不带 frontmatter 的内容
sed '1,/^---$/d; 1,/^---$/d' .claude/epics/$ARGUMENTS/epic.md > /tmp/epic-body-raw.md

# 移除 "## Tasks Created" 部分并替换为统计信息
awk '
  /^## Tasks Created/ { 
    in_tasks=1
    next
  }
  /^## / && in_tasks { 
    in_tasks=0
    # 当我们到达 Tasks Created 后的下一个部分时，添加统计信息
    if (total_tasks) {
      print "## Stats\n"
      print "Total tasks: " total_tasks
      print "Parallel tasks: " parallel_tasks " (can be worked on simultaneously)"
      print "Sequential tasks: " sequential_tasks " (have dependencies)"
      if (total_effort) print "Estimated total effort: " total_effort " hours"
      print ""
    }
  }
  /^Total tasks:/ && in_tasks { total_tasks = $3; next }
  /^Parallel tasks:/ && in_tasks { parallel_tasks = $3; next }
  /^Sequential tasks:/ && in_tasks { sequential_tasks = $3; next }
  /^Estimated total effort:/ && in_tasks { 
    gsub(/^Estimated total effort: /, "")
    total_effort = $0
    next 
  }
  !in_tasks { print }
  END {
    # 如果我们在文件末尾仍在任务部分，添加统计信息
    if (in_tasks && total_tasks) {
      print "## Stats\n"
      print "Total tasks: " total_tasks
      print "Parallel tasks: " parallel_tasks " (can be worked on simultaneously)"
      print "Sequential tasks: " sequential_tasks " (have dependencies)"
      if (total_effort) print "Estimated total effort: " total_effort
    }
  }
' /tmp/epic-body-raw.md > /tmp/epic-body.md

# 从内容中确定 epic 类型（功能 vs 错误）
if grep -qi "bug\\|fix\\|issue\\|problem\\|error" /tmp/epic-body.md; then
  epic_type="bug"
else
  epic_type="feature"
fi

# 使用标签创建 epic 问题
epic_number=$(gh issue create \
  --title "Epic: $ARGUMENTS" \
  --body-file /tmp/epic-body.md \
  --label "epic,epic:$ARGUMENTS,$epic_type" \
  --json number -q .number)
```

存储返回的问题编号以更新 epic frontmatter。

### 2. 创建任务子问题

检查 gh-sub-issue 是否可用：
```bash
if gh extension list | grep -q "yahsan2/gh-sub-issue"; then
  use_subissues=true
else
  use_subissues=false
  echo "⚠️ gh-sub-issue 未安装。使用回退模式。"
fi
```

统计任务文件以确定策略：
```bash
task_count=$(ls .claude/epics/$ARGUMENTS/[0-9][0-9][0-9].md 2>/dev/null | wc -l)
```

### 对于小批量 (< 5 个任务)：顺序创建

```bash
if [ "$task_count" -lt 5 ]; then
  # 对于小批量顺序创建
  for task_file in .claude/epics/$ARGUMENTS/[0-9][0-9][0-9].md; do
    [ -f "$task_file" ] || continue
    
    # 从 frontmatter 提取任务名称
    task_name=$(grep '^name:' "$task_file" | sed 's/^name: *//')
    
    # 从任务内容中剥离 frontmatter
    sed '1,/^---$/d; 1,/^---$/d' "$task_file" > /tmp/task-body.md
    
    # 使用标签创建子问题
    if [ "$use_subissues" = true ]; then
      task_number=$(gh sub-issue create \
        --parent "$epic_number" \
        --title "$task_name" \
        --body-file /tmp/task-body.md \
        --label "task,epic:$ARGUMENTS" \
        --json number -q .number)
    else
      task_number=$(gh issue create \
        --title "$task_name" \
        --body-file /tmp/task-body.md \
        --label "task,epic:$ARGUMENTS" \
        --json number -q .number)
    fi
    
    # 记录映射以重命名
    echo "$task_file:$task_number" >> /tmp/task-mapping.txt
  done
  
  # 创建所有问题后，更新引用并重命名文件
  # 这遵循与下面第 3 步相同的流程
fi
```

### 对于大批量：并行创建

```bash
if [ "$task_count" -ge 5 ]; then
  echo "并行创建 $task_count 个子问题..."
  
  # 检查 gh-sub-issue 是否可用于并行代理
  if gh extension list | grep -q "yahsan2/gh-sub-issue"; then
    subissue_cmd="gh sub-issue create --parent $epic_number"
  else
    subissue_cmd="gh issue create"
  fi
  
  # 批量处理任务以进行并行处理
  # 生成代理以并行创建子问题
  # 每个代理必须使用: --label "task,epic:$ARGUMENTS"
fi
```

使用 Task 工具进行并行创建：
```yaml
Task:
  description: "创建 GitHub 子问题批次 {X}"
  subagent_type: "general-purpose"
  prompt: |
    为 epic $ARGUMENTS 中的任务创建 GitHub 子问题
    父 epic 问题: #$epic_number
    
    要处理的任务:
    - {任务文件列表}
    
    对于每个任务文件:
    1. 从 frontmatter 提取任务名称
    2. 使用以下命令剥离 frontmatter: sed '1,/^---$/d; 1,/^---$/d'
    3. 创建子问题使用:
       - 如果 gh-sub-issue 可用: 
         gh sub-issue create --parent $epic_number --title "$task_name" \
           --body-file /tmp/task-body.md --label "task,epic:$ARGUMENTS"
       - 否则: 
         gh issue create --title "$task_name" --body-file /tmp/task-body.md \
           --label "task,epic:$ARGUMENTS"
    4. 记录: task_file:issue_number
    
    重要: 始终包含 --label 参数，值为 "task,epic:$ARGUMENTS"
    
    返回文件到问题编号的映射。
```

整合并行代理的结果：
```bash
# 从代理收集所有映射
cat /tmp/batch-*/mapping.txt >> /tmp/task-mapping.txt

# 重要: 整合后，遵循第 3 步来:
# 1. 构建旧->新 ID 映射
# 2. 更新所有任务引用 (depends_on, conflicts_with)
# 3. 重命名文件并更新 frontmatter
```

### 3. 重命名任务文件并更新引用

首先，构建旧编号到新问题 ID 的映射：
```bash
# 创建从旧任务编号 (001, 002, 等) 到新问题 ID 的映射
> /tmp/id-mapping.txt
while IFS=: read -r task_file task_number; do
  # 从文件名提取旧编号 (例如, 从 001.md 提取 001)
  old_num=$(basename "$task_file" .md)
  echo "$old_num:$task_number" >> /tmp/id-mapping.txt
done < /tmp/task-mapping.txt
```

然后重命名文件并更新所有引用：
```bash
# 处理每个任务文件
while IFS=: read -r task_file task_number; do
  new_name="$(dirname "$task_file")/${task_number}.md"
  
  # 读取文件内容
  content=$(cat "$task_file")
  
  # 更新 depends_on 和 conflicts_with 引用
  while IFS=: read -r old_num new_num; do
    # 更新数组如 [001, 002] 以使用新问题编号
    content=$(echo "$content" | sed "s/\b$old_num\b/$new_num/g")
  done < /tmp/id-mapping.txt
  
  # 将更新后的内容写入新文件
  echo "$content" > "$new_name"
  
  # 如果新文件名与旧文件名不同，则删除旧文件
  [ "$task_file" != "$new_name" ] && rm "$task_file"
  
  # 更新 frontmatter 中的 github 字段
  # 将 GitHub URL 添加到 frontmatter
  repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
  github_url="https://github.com/$repo/issues/$task_number"
  
  # 使用当前时间戳更新 frontmatter
  current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  # 使用 sed 更新 github 和 updated 字段
  sed -i.bak "/^github:/c\github: $github_url" "$new_name"
  sed -i.bak "/^updated:/c\updated: $current_date" "$new_name"
  rm "${new_name}.bak"
done < /tmp/task-mapping.txt
```

### 4. 更新 Epic 任务列表 (仅回退)

如果不使用 gh-sub-issue，将任务列表添加到 epic：

```bash
if [ "$use_subissues" = false ]; then
  # 获取当前 epic 正文
  gh issue view {epic_number} --json body -q .body > /tmp/epic-body.md
  
  # 追加任务列表
  cat >> /tmp/epic-body.md << 'EOF'
  
  ## Tasks
  - [ ] #{task1_number} {task1_name}
  - [ ] #{task2_number} {task2_name}
  - [ ] #{task3_number} {task3_name}
  EOF
  
  # 更新 epic 问题
  gh issue edit {epic_number} --body-file /tmp/epic-body.md
fi
```

使用 gh-sub-issue 时，这是自动的！

### 5. 更新 Epic 文件

使用 GitHub URL、时间戳和真实任务 ID 更新 epic 文件：

#### 5a. 更新 Frontmatter
```bash
# 获取仓库信息
repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
epic_url="https://github.com/$repo/issues/$epic_number"
current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 更新 epic frontmatter
sed -i.bak "/^github:/c\github: $epic_url" .claude/epics/$ARGUMENTS/epic.md
sed -i.bak "/^updated:/c\updated: $current_date" .claude/epics/$ARGUMENTS/epic.md
rm .claude/epics/$ARGUMENTS/epic.md.bak
```

#### 5b. 更新任务创建部分
```bash
# 创建包含更新任务创建部分的临时文件
cat > /tmp/tasks-section.md << 'EOF'
## Tasks Created
EOF

# 添加每个任务及其真实问题编号
for task_file in .claude/epics/$ARGUMENTS/[0-9]*.md; do
  [ -f "$task_file" ] || continue
  
  # 获取问题编号 (不带 .md 的文件名)
  issue_num=$(basename "$task_file" .md)
  
  # 从 frontmatter 获取任务名称
  task_name=$(grep '^name:' "$task_file" | sed 's/^name: *//')
  
  # 获取并行状态
  parallel=$(grep '^parallel:' "$task_file" | sed 's/^parallel: *//')
  
  # 添加到任务部分
  echo "- [ ] #${issue_num} - ${task_name} (parallel: ${parallel})" >> /tmp/tasks-section.md
done

# 添加摘要统计信息
total_count=$(ls .claude/epics/$ARGUMENTS/[0-9]*.md 2>/dev/null | wc -l)
parallel_count=$(grep -l '^parallel: true' .claude/epics/$ARGUMENTS/[0-9]*.md 2>/dev/null | wc -l)
sequential_count=$((total_count - parallel_count))

cat >> /tmp/tasks-section.md << EOF

Total tasks: ${total_count}
Parallel tasks: ${parallel_count}
Sequential tasks: ${sequential_count}
EOF

# 在 epic.md 中替换任务创建部分
# 首先，创建备份
cp .claude/epics/$ARGUMENTS/epic.md .claude/epics/$ARGUMENTS/epic.md.backup

# 使用 awk 替换部分
awk '
  /^## Tasks Created/ { 
    skip=1
    while ((getline line < "/tmp/tasks-section.md") > 0) print line
    close("/tmp/tasks-section.md")
  }
  /^## / && !/^## Tasks Created/ { skip=0 }
  !skip && !/^## Tasks Created/ { print }
' .claude/epics/$ARGUMENTS/epic.md.backup > .claude/epics/$ARGUMENTS/epic.md

# 清理
rm .claude/epics/$ARGUMENTS/epic.md.backup
rm /tmp/tasks-section.md
```

### 6. 创建映射文件

创建 `.claude/epics/$ARGUMENTS/github-mapping.md`：
```bash
# 创建映射文件
cat > .claude/epics/$ARGUMENTS/github-mapping.md << EOF
# GitHub 问题映射

Epic: #${epic_number} - https://github.com/${repo}/issues/${epic_number}

Tasks:
EOF

# 添加每个任务映射
for task_file in .claude/epics/$ARGUMENTS/[0-9]*.md; do
  [ -f "$task_file" ] || continue
  
  issue_num=$(basename "$task_file" .md)
  task_name=$(grep '^name:' "$task_file" | sed 's/^name: *//')
  
  echo "- #${issue_num}: ${task_name} - https://github.com/${repo}/issues/${issue_num}" >> .claude/epics/$ARGUMENTS/github-mapping.md
done

# 添加同步时间戳
echo "" >> .claude/epics/$ARGUMENTS/github-mapping.md
echo "Synced: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> .claude/epics/$ARGUMENTS/github-mapping.md
```

### 7. 创建工作树

遵循 `/rules/worktree-operations.md` 创建开发工作树：

```bash
# 确保 main 是最新的
git checkout main
git pull origin main

# 为 epic 创建工作树
git worktree add ../epic-$ARGUMENTS -b epic/$ARGUMENTS

echo "✅ 已创建工作树: ../epic-$ARGUMENTS"
```

### 8. 输出

```
✅ 已同步到 GitHub
  - Epic: #{epic_number} - {epic_title}
  - 任务: {count} 个子问题已创建
  - 已应用标签: epic, task, epic:{name}
  - 文件已重命名: 001.md → {issue_id}.md
  - 引用已更新: depends_on/conflicts_with 现在使用问题 ID
  - 工作树: ../epic-$ARGUMENTS

下一步:
  - 开始并行执行: /pm:epic-start $ARGUMENTS
  - 或处理单个问题: /pm:issue-start {issue_number}
  - 查看 epic: https://github.com/{owner}/{repo}/issues/{epic_number}
```

## 错误处理

遵循 `/rules/github-operations.md` 处理 GitHub CLI 错误。

如果任何问题创建失败：
- 报告成功的部分
- 记录失败的部分
- 不要尝试回滚 (部分同步是可以的)

## 重要说明

- 信任 GitHub CLI 认证
- 不要预先检查重复项
- 仅在创建成功后更新 frontmatter
- 保持操作简单和原子性