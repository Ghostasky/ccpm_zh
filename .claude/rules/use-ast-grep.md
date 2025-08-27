# Cursor 代理的 AST-Grep 集成协议

## 何时使用 AST-Grep

在以下情况下使用 `ast-grep`（如果已安装）而不是普通正则表达式或文本搜索：

- **涉及结构化代码模式**（例如，查找所有函数调用、类定义或方法实现）
- **需要语言感知的重构**（例如，重命名变量、更新函数签名或更改导入）
- **需要复杂的代码分析**（例如，基于不同语法上下文查找模式的所有用法）
- **需要跨语言搜索**（例如，在 monorepo 中同时处理 Ruby 和 TypeScript）
- **语义代码理解很重要**（例如，基于代码结构而不是文本查找模式）

## AST-Grep 命令模式

### 基本搜索模板：
```sh
ast-grep --pattern '$PATTERN' --lang $LANGUAGE $PATH
```

### 常见用例

- **查找函数调用：**
  `ast-grep --pattern 'functionName($$$)' --lang javascript .`
- **查找类定义：**
  `ast-grep --pattern 'class $NAME { $$$ }' --lang typescript .`
- **查找变量赋值：**
  `ast-grep --pattern '$VAR = $$$' --lang ruby .`
- **查找导入语句：**
  `ast-grep --pattern 'import { $$$ } from "$MODULE"' --lang javascript .`
- **查找对象上的方法调用：**
  `ast-grep --pattern '$OBJ.$METHOD($$$)' --lang typescript .`
- **查找 React hooks：**
  `ast-grep --pattern 'const [$STATE, $SETTER] = useState($$$)' --lang typescript .`
- **查找 Ruby 类定义：**
  `ast-grep --pattern 'class $NAME < $$$; $$$; end' --lang ruby .`

## 模式语法参考

- `$VAR` — 匹配任何单个节点并捕获它
- `$$$` — 匹配零个或多个节点（通配符）
- `$$` — 匹配一个或多个节点
- 字面代码 — 精确匹配所写内容

## 支持的语言

- javascript, typescript, ruby, python, go, rust, java, c, cpp, html, css, yaml, json 等

## 集成工作流

### 使用 ast-grep 之前：
1. **检查是否已安装 ast-grep：**
   如果没有，则跳过并回退到正则表达式/语义搜索。
   ```sh
   command -v ast-grep >/dev/null 2>&1 || echo "ast-grep 未安装，跳过 AST 搜索"
   ```
2. **识别** 任务是否涉及结构化代码模式或语言感知的重构。
3. **确定** 要搜索的适当语言。
4. **使用 ast-grep 语法构造** 模式。
5. **运行** ast-grep 以收集精确的结构化信息。
6. **使用** 结果来指导代码编辑、重构或进一步分析。

### 示例工作流

当被要求"查找所有调用 `perform` 的 Ruby 服务对象"时：

1. **检查 ast-grep：**
   ```sh
   command -v ast-grep >/dev/null 2>&1 && ast-grep --pattern 'perform($$$)' --lang ruby app/services/
   ```
2. **结构化分析** 结果。
3. **使用** 代码库语义搜索获取更多上下文（如果需要）。
4. **基于结构化理解进行** 知识渊博的编辑。

### 将 ast-grep 与内部工具结合使用

- **codebase_search** 用于语义上下文和文档
- **read_file** 用于检查 ast-grep 找到的特定文件
- **edit_file** 用于进行精确的、具有上下文感知的代码更改

### 高级用法
- **用于程序化处理的 JSON 输出：**
  `ast-grep --pattern '$PATTERN' --lang $LANG $PATH --json`
- **替换模式：**
  `ast-grep --pattern '$OLD_PATTERN' --rewrite '$NEW_PATTERN' --lang $LANG $PATH`
- **交互模式：**
  `ast-grep --pattern '$PATTERN' --lang $LANG $PATH --interactive`

## 相对于正则表达式的关键优势

1. **语言感知** — 理解语法和语义
2. **结构化匹配** — 无论格式如何都能找到模式
3. **跨语言** — 在不同语言中一致工作
4. **精确重构** — 安全地进行结构化更改
5. **上下文感知** — 理解代码层次结构和作用域

## 决策矩阵：何时使用每种工具

| 任务类型                | 工具选择             | 原因                          |
|--------------------------|----------------------|-------------------------------|
| 查找文本模式            | grep_search          | 简单的文本匹配                |
| 查找代码结构            | ast-grep             | 语法感知搜索                  |
| 理解语义                | codebase_search      | AI 驱动的上下文                |
| 进行编辑                | edit_file            | 精确的文件编辑                |
| 结构化重构              | ast-grep + edit_file | 结构 + 精度                   |

**始终优先使用 ast-grep 进行代码结构分析，而不是基于正则表达式的方法，但前提是它已安装且可用。**