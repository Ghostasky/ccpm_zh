#!/bin/bash

echo "获取状态中..."
echo ""
echo ""

epic_name="$1"

if [ -z "$epic_name" ]; then
  echo "❌ 请指定史诗任务名称"
  echo "用法: /pm:epic-status <epic-name>"
  echo ""
  echo "可用史诗任务:"
  for dir in .claude/epics/*/; do
    [ -d "$dir" ] && echo "  • $(basename "$dir")"
  done
  exit 1
else
  # 显示特定史诗任务的状态
  epic_dir=".claude/epics/$epic_name"
  epic_file="$epic_dir/epic.md"

  if [ ! -f "$epic_file" ]; then
    echo "❌ 未找到史诗任务: $epic_name"
    echo ""
    echo "可用史诗任务:"
    for dir in .claude/epics/*/; do
      [ -d "$dir" ] && echo "  • $(basename "$dir")"
    done
    exit 1
  fi

  echo "📚 史诗任务状态: $epic_name"
  echo "================================"
  echo ""

  # 提取元数据
  status=$(grep "^status:" "$epic_file" | head -1 | sed 's/^status: *//')
  progress=$(grep "^progress:" "$epic_file" | head -1 | sed 's/^progress: *//')
  github=$(grep "^github:" "$epic_file" | head -1 | sed 's/^github: *//')

  # 计算任务数
  total=0
  open=0
  closed=0
  blocked=0

  # 使用 find 安全地遍历任务文件
  for task_file in "$epic_dir"/[0-9]*.md; do
    [ -f "$task_file" ] || continue
    ((total++))

    task_status=$(grep "^status:" "$task_file" | head -1 | sed 's/^status: *//')
    deps=$(grep "^depends_on:" "$task_file" | head -1 | sed 's/^depends_on: *\[//' | sed 's/\]//')

    if [ "$task_status" = "closed" ] || [ "$task_status" = "completed" ]; then
      ((closed++))
    elif [ -n "$deps" ] && [ "$deps" != "depends_on:" ]; then
      ((blocked++))
    else
      ((open++))
    fi
  done

  # 显示进度条
  if [ $total -gt 0 ]; then
    percent=$((closed * 100 / total))
    filled=$((percent * 20 / 100))
    empty=$((20 - filled))

    echo -n "进度: ["
    [ $filled -gt 0 ] && printf '%0.s█' $(seq 1 $filled)
    [ $empty -gt 0 ] && printf '%0.s░' $(seq 1 $empty)
    echo "] $percent%"
  else
    echo "进度: 未创建任务"
  fi

  echo ""
  echo "📊 分解:"
  echo "  总任务数: $total"
  echo "  ✅ 已完成: $closed"
  echo "  🔄 可用: $open"
  echo "  ⏸️ 被阻塞: $blocked"

  [ -n "$github" ] && echo ""
  [ -n "$github" ] && echo "🔗 GitHub: $github"
fi

exit 0