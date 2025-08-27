---
allowed-tools: Bash, Read, Write, LS
---

# 启动测试环境

此命令通过检测测试框架、验证依赖项并配置 test-runner 代理来准备测试环境，以实现最佳的测试执行。

## 预检清单

在继续之前，请完成这些验证步骤。
不要用预检检查进度打扰用户（"我不会..."）。只需完成它们并继续。

### 1. 测试框架检测

**JavaScript/Node.js:**
- 检查 package.json 中的测试脚本：`grep -E '"test"|"spec"|"jest"|"mocha"' package.json 2>/dev/null`
- 查找测试配置文件：`ls -la jest.config.* mocha.opts .mocharc.* 2>/dev/null`
- 检查测试目录：`find . -type d \\( -name "test" -o -name "tests" -o -name "__tests__" -o -name "spec" \\) -maxdepth 3 2>/dev/null`

**Python:**
- 检查 pytest：`find . -name "pytest.ini" -o -name "conftest.py" -o -name "setup.cfg" 2>/dev/null | head -5`
- 检查 unittest：`find . -path "*/test*.py" -o -path "*/test_*.py" 2>/dev/null | head -5`
- 检查 requirements：`grep -E "pytest|unittest|nose" requirements.txt 2>/dev/null`

**Rust:**
- 检查 Cargo 测试：`grep -E '\[dev-dependencies\]' Cargo.toml 2>/dev/null`
- 查找测试模块：`find . -name "*.rs" -exec grep -l "#\\[cfg(test)\\]" {} \\; 2>/dev/null | head -5`

**Go:**
- 检查测试文件：`find . -name "*_test.go" 2>/dev/null | head -5`
- 检查 go.mod 是否存在：`test -f go.mod && echo "找到 Go 模块"`

**其他语言:**
- Ruby: 检查 RSpec：`find . -name ".rspec" -o -name "spec_helper.rb" 2>/dev/null`
- Java: 检查 JUnit：`find . -name "pom.xml" -exec grep -l "junit" {} \\; 2>/dev/null`

### 2. 测试环境验证

如果未检测到测试框架：
- 告诉用户："⚠️ 未检测到测试框架。请指定您的测试设置。"
- 询问："我应该使用什么测试命令？（例如，npm test、pytest、cargo test）"
- 存储响应以供将来使用

### 3. 依赖项检查

**对于检测到的框架：**
- Node.js: 运行 `npm list --depth=0 2>/dev/null | grep -E "jest|mocha|chai|jasmine"`
- Python: 运行 `pip list 2>/dev/null | grep -E "pytest|unittest|nose"`
- 验证测试依赖项是否已安装

如果依赖项缺失：
- 告诉用户："❌ 测试依赖项未安装"
- 建议："运行: npm install（或 pip install -r requirements.txt）"

## 指令

### 1. 框架特定配置

根据检测到的框架，创建测试配置：

#### JavaScript/Node.js (Jest)
```yaml
framework: jest
test_command: npm test
test_directory: __tests__
config_file: jest.config.js
options:
  - --verbose
  - --no-coverage
  - --runInBand
environment:
  NODE_ENV: test
```

#### JavaScript/Node.js (Mocha)
```yaml
framework: mocha
test_command: npm test
test_directory: test
config_file: .mocharc.js
options:
  - --reporter spec
  - --recursive
  - --bail
environment:
  NODE_ENV: test
```

#### Python (Pytest)
```yaml
framework: pytest
test_command: pytest
test_directory: tests
config_file: pytest.ini
options:
  - -v
  - --tb=short
  - --strict-markers
environment:
  PYTHONPATH: .
```

#### Rust
```yaml
framework: cargo
test_command: cargo test
test_directory: tests
config_file: Cargo.toml
options:
  - --verbose
  - --nocapture
environment: {}
```

#### Go
```yaml
framework: go
test_command: go test
test_directory: .
config_file: go.mod
options:
  - -v
  - ./...
environment: {}
```

### 2. 测试发现

扫描测试文件：
- 统计找到的测试文件总数
- 识别使用的测试命名模式
- 注意任何测试工具或助手
- 检查测试夹具或数据

```bash
# Node.js 示例
find . -path "*/node_modules" -prune -o -name "*.test.js" -o -name "*.spec.js" | wc -l
```

### 3. 创建测试运行器配置

创建 `.claude/testing-config.md` 并包含发现的信息：

```markdown
---
framework: {detected_framework}
test_command: {detected_command}
created: [使用来自以下命令的真实日期时间: date -u +"%Y-%m-%dT%H:%M:%SZ"]
---

# 测试配置

## 框架
- 类型: {framework_name}
- 版本: {framework_version}
- 配置文件: {config_file_path}

## 测试结构
- 测试目录: {test_dir}
- 测试文件: {count} 个文件找到
- 命名模式: {pattern}

## 命令
- 运行所有测试: `{full_test_command}`
- 运行特定测试: `{specific_test_command}`
- 带调试运行: `{debug_command}

## 环境
- 需要的环境变量: {list}
- 测试数据库: {if applicable}
- 测试服务器: {if applicable}

## 测试运行器代理配置
- 使用详细输出进行调试
- 顺序运行测试（无并行）
- 捕获完整堆栈跟踪
- 无模拟 - 使用真实实现
- 等待每个测试完成
```

### 4. 配置测试运行器代理

根据框架准备代理上下文：

```markdown
# 测试运行器代理配置

## 项目测试设置
- 框架: {framework}
- 测试位置: {directories}
- 总测试数: {count}
- 最后运行: 从未

## 执行规则
1. 始终使用来自 `.claude/agents/test-runner.md` 的测试运行器代理
2. 使用最大详细程度进行调试
3. 无模拟服务 - 使用真实实现
4. 顺序执行测试 - 无并行执行
5. 捕获完整输出包括堆栈跟踪
6. 如果测试失败，在假设代码问题之前分析测试结构
7. 报告带有上下文的详细失败分析

## 测试命令模板
- 完整套件: `{full_command}`
- 单个文件: `{single_file_command}`
- 模式匹配: `{pattern_command}`
- 监视模式: `{watch_command}`（如果可用）

## 要检查的常见问题
- 环境变量正确设置
- 测试数据库/服务运行
- 依赖项已安装
- 正确的文件权限
- 运行间清理测试状态
```

### 5. 验证步骤

配置后：
- 尝试运行简单测试以验证设置
- 检查测试命令是否工作：`{test_command} --version` 或等效命令
- 验证测试文件是否可发现
- 确保无权限问题

### 6. 输出摘要

```
🧪 测试环境已启动

🔍 检测结果:
  ✅ 框架: {framework_name} {version}
  ✅ 测试文件: {count} 个文件在 {directories} 中
  ✅ 配置: {config_file}
  ✅ 依赖项: 全部已安装

📋 测试结构:
  - 模式: {test_file_pattern}
  - 目录: {test_directories}
  - 工具: {test_helpers}

🤖 代理配置:
  ✅ 测试运行器代理已配置
  ✅ 详细输出已启用
  ✅ 顺序执行已设置
  ✅ 真实服务（无模拟）

⚡ 就绪命令:
  - 运行所有测试: /testing:run
  - 运行特定测试: /testing:run {test_file}
  - 运行模式: /testing:run {pattern}

💡 提示:
  - 始终使用详细输出运行测试
  - 如果测试失败请检查测试结构
  - 使用真实服务，而不是模拟
  - 让每个测试完全完成
```

### 7. 错误处理

**常见问题：**

**未检测到框架：**
- 消息："⚠️ 未找到测试框架"
- 解决方案："请手动指定测试命令"
- 存储用户的响应以供将来使用

**依赖项缺失：**
- 消息："❌ 测试框架未安装"
- 解决方案："首先安装依赖项: npm install / pip install -r requirements.txt"

**无测试文件：**
- 消息："⚠️ 未找到测试文件"
- 解决方案："首先创建测试或检查测试目录位置"

**权限问题：**
- 消息："❌ 无法访问测试文件"
- 解决方案："检查文件权限"

### 8. 保存配置

如果成功，保存配置以供将来会话使用：
- 存储在 `.claude/testing-config.md` 中
- 包含所有发现的设置
- 在后续运行中如果检测到变更则更新

## 重要说明

- **始终检测** 而不是假设测试框架
- **验证依赖项** 在声明就绪之前
- **配置用于调试** - 详细输出至关重要
- **无模拟** - 使用真实服务进行准确测试
- **顺序执行** - 避免并行测试问题
- **存储配置** 以实现一致的将来运行

$ARGUMENTS