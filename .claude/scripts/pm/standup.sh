#!/bin/bash

echo "📅 每日站会 - $(date '+%Y-%m-%d')"
echo "================================"
echo ""

today=$(date '+%Y-%m-%d')

echo "获取状态中..."
echo ""
echo ""

echo "📝 今日活动:"
echo "===================="
echo ""

# 查找今日修改的文件
recent_files=$(find .claude -name "*.md" -mtime -1 2>/dev/null)

if [ -n "$recent_files" ]; then
  # 按类型计数
  prd_count=$(echo "$recent_files" | grep -c "/prds/" || echo 0)
  epic_count=$(echo "$recent_files" | grep -c "/epic.md" || echo 0)
  task_count=$(echo "$recent_files" | grep -c "/[0-9]*.md" || echo 0)
  update_count=$(echo "$recent_files" | grep -c "/updates/" || echo 0)

  [ $prd_count -gt 0 ] && echo "  • 修改了 $prd_count 个 PRD"
  [ $epic_count -gt 0 ] && echo "  • 更新了 $epic_count 个史诗任务"
  [ $task_count -gt 0 ] && echo "  • 处理了 $task_count 个任务"
  [ $update_count -gt 0 ] && echo "  • 发布了 $update_count 个进度更新"
else
  echo "  今日无活动记录"
fi

echo ""
echo "🔄 当前进行中:"
# 显示活跃工作项
for updates_dir in .claude/epics/*/updates/*/; do
  [ -d "$updates_dir" ] || continue
  if [ -f "$updates_dir/progress.md" ]; then
    issue_num=$(basename "$updates_dir")
    epic_name=$(basename $(dirname $(dirname "$updates_dir")))
    completion=$(grep "^completion:" "$updates_dir/progress.md" | head -1 | sed 's/^completion: *//')
    echo "  • Issue #$issue_num ($epic_name) - ${completion:-0%} 完成"
  fi
done

echo ""
echo "⏭️ 下一个可用任务:"
# 显示前 3 个可用任务
count=0
for epic_dir in .claude/epics/*/; do
  [ -d "$epic_dir" ] || continue
  for task_file in "$epic_dir"[0-9]*.md; do
    [ -f "$task_file" ] || continue
    status=$(grep "^status:" "$task_file" | head -1 | sed 's/^status: *//')
    [ "$status" != "open" ] && [ -n "$status" ] && continue

    deps=$(grep "^depends_on:" "$task_file" | head -1 | sed 's/^depends_on: *\[//' | sed 's/\]//')
    if [ -z "$deps" ] || [ "$deps" = "depends_on:" ]; then
      task_name=$(grep "^name:" "$task_file" | head -1 | sed 's/^name: *//')
      task_num=$(basename "$task_file" .md)
      echo "  • #$task_num - $task_name"
      ((count++))
      [ $count -ge 3 ] && break 2
    fi
  done
done

echo ""
echo "📊 快速统计:"
total_tasks=$(find .claude/epics -name "[0-9]*.md" 2>/dev/null | wc -l)
open_tasks=$(find .claude/epics -name "[0-9]*.md" -exec grep -l "^status: *open" {} \; 2>/dev/null | wc -l)
closed_tasks=$(find .claude/epics -name "[0-9]*.md" -exec grep -l "^status: *closed" {} \; 2>/dev/null | wc -l)
echo "  任务: $open_tasks 开放, $closed_tasks 已关闭, $total_tasks 总计"

exit 0