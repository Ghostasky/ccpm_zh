#!/bin/bash

epic_name="$1"

if [ -z "$epic_name" ]; then
  echo "❌ 请提供史诗任务名称"
  echo "用法: /pm:epic-show <epic-name>"
  exit 1
fi

echo "获取史诗任务中..."
echo ""
echo ""

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

# 显示史诗任务详情
echo "📚 史诗任务: $epic_name"
echo "================================"
echo ""

# 提取元数据
status=$(grep "^status:" "$epic_file" | head -1 | sed 's/^status: *//')
progress=$(grep "^progress:" "$epic_file" | head -1 | sed 's/^progress: *//')
github=$(grep "^github:" "$epic_file" | head -1 | sed 's/^github: *//')
created=$(grep "^created:" "$epic_file" | head -1 | sed 's/^created: *//')

echo "📊 元数据:"
echo "  状态: ${status:-planning}"
echo "  进度: ${progress:-0%}"
[ -n "$github" ] && echo "  GitHub: $github"
echo "  创建时间: ${created:-unknown}"
echo ""

# 显示任务
echo "📝 任务:"
task_count=0
open_count=0
closed_count=0

for task_file in "$epic_dir"/[0-9]*.md; do
  [ -f "$task_file" ] || continue

  task_num=$(basename "$task_file" .md)
  task_name=$(grep "^name:" "$task_file" | head -1 | sed 's/^name: *//')
  task_status=$(grep "^status:" "$task_file" | head -1 | sed 's/^status: *//')
  parallel=$(grep "^parallel:" "$task_file" | head -1 | sed 's/^parallel: *//')

  if [ "$task_status" = "closed" ] || [ "$task_status" = "completed" ]; then
    echo "  ✅ #$task_num - $task_name"
    ((closed_count++))
  else
    echo "  ⬜ #$task_num - $task_name"
    [ "$parallel" = "true" ] && echo -n " (并行)"
    ((open_count++))
  fi

  ((task_count++))
done

if [ $task_count -eq 0 ]; then
  echo "  尚未创建任务"
  echo "  运行: /pm:epic-decompose $epic_name"
fi

echo ""
echo "📈 统计:"
echo "  总任务数: $task_count"
echo "  开放: $open_count"
echo "  已关闭: $closed_count"
[ $task_count -gt 0 ] && echo "  完成度: $((closed_count * 100 / task_count))%"

# 下一步操作
echo ""
echo "💡 操作:"
[ $task_count -eq 0 ] && echo "  • 分解为任务: /pm:epic-decompose $epic_name"
[ -z "$github" ] && [ $task_count -gt 0 ] && echo "  • 同步到 GitHub: /pm:epic-sync $epic_name"
[ -n "$github" ] && [ "$status" != "completed" ] && echo "  • 开始工作: /pm:epic-start $epic_name"

exit 0