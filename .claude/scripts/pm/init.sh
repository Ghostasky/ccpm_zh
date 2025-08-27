#!/bin/bash

echo "初始化中..."
echo ""
echo ""

echo " ██████╗ ██████╗██████╗ ███╗   ███╗"
echo "██╔════╝██╔════╝██╔══██╗████╗ ████║"
echo "██║     ██║     ██████╔╝██╔████╔██║"
echo "╚██████╗╚██████╗██║     ██║ ╚═╝ ██║"
echo " ╚═════╝ ╚═════╝╚═╝     ╚═╝     ╚═╝"

echo "┌─────────────────────────────────┐"
echo "│ Claude Code 项目管理            │"
echo "│ 由 https://x.com/aroussi        │"
echo "└─────────────────────────────────┘"
echo "https://github.com/automazeio/ccpm"
echo ""
echo ""

echo "🚀 初始化 Claude Code PM 系统"
echo "======================================"
echo ""

# 检查所需工具
echo "🔍 检查依赖项..."

# 检查 gh CLI
if command -v gh &> /dev/null; then
  echo "  ✅ GitHub CLI (gh) 已安装"
else
  echo "  ❌ GitHub CLI (gh) 未找到"
  echo ""
  echo "  正在安装 gh..."
  if command -v brew &> /dev/null; then
    brew install gh
  elif command -v apt-get &> /dev/null; then
    sudo apt-get update && sudo apt-get install gh
  else
    echo "  请手动安装 GitHub CLI: https://cli.github.com/"
    exit 1
  fi
fi

# 检查 gh 认证状态
echo ""
echo "🔐 检查 GitHub 认证..."
if gh auth status &> /dev/null; then
  echo "  ✅ GitHub 已认证"
else
  echo "  ⚠️ GitHub 未认证"
  echo "  运行: gh auth login"
  gh auth login
fi

# 检查 gh 扩展
echo ""
echo "📦 检查 gh 扩展..."
if gh extension list | grep -q "yahsan2/gh-sub-issue"; then
  echo "  ✅ gh-sub-issue 扩展已安装"
else
  echo "  📥 正在安装 gh-sub-issue 扩展..."
  gh extension install yahsan2/gh-sub-issue
fi

# 创建目录结构
echo ""
echo "📁 创建目录结构..."
mkdir -p .claude/prds
mkdir -p .claude/epics
mkdir -p .claude/rules
mkdir -p .claude/agents
mkdir -p .claude/scripts/pm
echo "  ✅ 目录已创建"

# 如果在主仓库中则复制脚本
if [ -d "scripts/pm" ] && [ ! "$(pwd)" = *"/.claude"* ]; then
  echo ""
  echo "📝 复制 PM 脚本..."
  cp -r scripts/pm/* .claude/scripts/pm/
  chmod +x .claude/scripts/pm/*.sh
  echo "  ✅ 脚本已复制并设为可执行"
fi

# 检查 git
echo ""
echo "🔗 检查 Git 配置..."
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo "  ✅ 检测到 Git 仓库"

  # 检查远程仓库
  if git remote -v | grep -q origin; then
    remote_url=$(git remote get-url origin)
    echo "  ✅ 远程仓库已配置: $remote_url"
  else
    echo "  ⚠️ 未配置远程仓库"
    echo "  添加命令: git remote add origin <url>"
  fi
else
  echo "  ⚠️ 不是 Git 仓库"
  echo "  初始化命令: git init"
fi

# 如果不存在则创建 CLAUDE.md
if [ ! -f "CLAUDE.md" ]; then
  echo ""
  echo "📄 创建 CLAUDE.md..."
  cat > CLAUDE.md << 'EOF'
# CLAUDE.md

> 仔细思考并实现改变最少代码的最简洁解决方案。

## 项目特定指令

在此添加您的项目特定指令。

## 测试

提交前始终运行测试：
- `npm test` 或您技术栈的等效命令

## 代码风格

遵循代码库中的现有模式。
EOF
  echo "  ✅ CLAUDE.md 已创建"
fi

# 摘要
echo ""
echo "✅ 初始化完成!"
echo "=========================="
echo ""
echo "📊 系统状态:"
gh --version | head -1
echo "  扩展: $(gh extension list | wc -l) 已安装"
echo "  认证: $(gh auth status 2>&1 | grep -o 'Logged in to [^ ]*' || echo '未认证')"
echo ""
echo "🎯 下一步:"
echo "  1. 创建您的第一个 PRD: /pm:prd-new <feature-name>"
echo "  2. 查看帮助: /pm:help"
echo "  3. 检查状态: /pm:status"
echo ""
echo "📚 文档: README.md"

exit 0