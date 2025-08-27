#!/bin/bash

echo "获取状态中..."
echo ""
echo ""


echo "📊 项目状态"
echo "================"
echo ""

echo "📄 PRD:"
if [ -d ".claude/prds" ]; then
  total=$(ls .claude/prds/*.md 2>/dev/null | wc -l)
  echo "  总数: $total"
else
  echo "  未找到 PRD"
fi

echo ""
echo "📚 史诗任务:"
if [ -d ".claude/epics" ]; then
  total=$(ls -d .claude/epics/*/ 2>/dev/null | wc -l)
  echo "  总数: $total"
else
  echo "  未找到史诗任务"
fi

echo ""
echo "📝 任务:"
if [ -d ".claude/epics" ]; then
  total=$(find .claude/epics -name "[0-9]*.md" 2>/dev/null | wc -l)
  open=$(find .claude/epics -name "[0-9]*.md" -exec grep -l "^status: *open" {} \; 2>/dev/null | wc -l)
  closed=$(find .claude/epics -name "[0-9]*.md" -exec grep -l "^status: *closed" {} \; 2>/dev/null | wc -l)
  echo "  开放: $open"
  echo "  已关闭: $closed"
  echo "  总数: $total"
else
  echo "  未找到任务"
fi

exit 0