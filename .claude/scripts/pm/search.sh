#!/bin/bash

query="$1"

if [ -z "$query" ]; then
  echo "❌ 请提供搜索查询"
  echo "用法: /pm:search <query>"
  exit 1
fi

echo "正在搜索 '$query'..."
echo ""
echo ""

echo "🔍 搜索结果: '$query'"
echo "================================"
echo ""

# 在 PRD 中搜索
if [ -d ".claude/prds" ]; then
  echo "📄 PRD:"
  results=$(grep -l -i "$query" .claude/prds/*.md 2>/dev/null)
  if [ -n "$results" ]; then
    for file in $results; do
      name=$(basename "$file" .md)
      matches=$(grep -c -i "$query" "$file")
      echo "  • $name ($matches 个匹配)"
    done
  else
    echo "  无匹配项"
  fi
  echo ""
fi

# 在史诗任务中搜索
if [ -d ".claude/epics" ]; then
  echo "📚 史诗任务:"
  results=$(find .claude/epics -name "epic.md" -exec grep -l -i "$query" {} \; 2>/dev/null)
  if [ -n "$results" ]; then
    for file in $results; do
      epic_name=$(basename $(dirname "$file"))
      matches=$(grep -c -i "$query" "$file")
      echo "  • $epic_name ($matches 个匹配)"
    done
  else
    echo "  无匹配项"
  fi
  echo ""
fi

# 在任务中搜索
if [ -d ".claude/epics" ]; then
  echo "📝 任务:"
  results=$(find .claude/epics -name "[0-9]*.md" -exec grep -l -i "$query" {} \; 2>/dev/null | head -10)
  if [ -n "$results" ]; then
    for file in $results; do
      epic_name=$(basename $(dirname "$file"))
      task_num=$(basename "$file" .md)
      echo "  • 史诗任务 $epic_name 中的任务 #$task_num"
    done
  else
    echo "  无匹配项"
  fi
fi

# 摘要
total=$(find .claude -name "*.md" -exec grep -l -i "$query" {} \; 2>/dev/null | wc -l)
echo ""
echo "📊 包含匹配项的文件总数: $total"

exit 0