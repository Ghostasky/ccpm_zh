---
allowed-tools: Bash, Read, Write, LS
---

# PRD 解析

将 PRD 转换为技术实现 epic。

## 用法
```
/pm:prd-parse <feature_name>
```

## 必需规则

**重要：** 在执行此命令之前，请阅读并遵循：
- `.claude/rules/datetime.md` - 用于获取真实的当前日期/时间

## 预检清单

在继续之前，请完成这些验证步骤。
不要用预检检查进度打扰用户（"我不会..."）。只需完成它们并继续。

### 验证步骤
1. **验证 <feature_name> 是否作为参数提供：**
   - 如果没有，告诉用户："❌ <feature_name> 未作为参数提供。请运行：/pm:prd-parse <feature_name>"
   - 如果未提供 <feature_name> 则停止执行

2. **验证 PRD 是否存在：**
   - 检查 `.claude/prds/$ARGUMENTS.md` 是否存在
   - 如果未找到，告诉用户："❌ 未找到 PRD：$ARGUMENTS。请先使用以下命令创建：/pm:prd-new $ARGUMENTS"
   - 如果 PRD 不存在则停止执行

3. **验证 PRD frontmatter：**
   - 验证 PRD 是否有有效的 frontmatter，包含：name、description、status、created
   - 如果 frontmatter 无效或缺失，告诉用户："❌ PRD frontmatter 无效。请检查：.claude/prds/$ARGUMENTS.md"
   - 显示缺失或无效的内容

4. **检查现有 epic：**
   - 检查 `.claude/epics/$ARGUMENTS/epic.md` 是否已存在
   - 如果存在，询问用户："⚠️ Epic '$ARGUMENTS' 已存在。是否覆盖？(yes/no)"
   - 仅在明确确认 'yes' 后继续
   - 如果用户说 no，建议："使用以下命令查看现有 epic：/pm:epic-show $ARGUMENTS"

5. **验证目录权限：**
   - 确保 `.claude/epics/` 目录存在或可以创建
   - 如果无法创建，告诉用户："❌ 无法创建 epic 目录。请检查权限。"

## 指令

您是一名技术负责人，正在将产品需求文档转换为详细的实现 epic，针对：**$ARGUMENTS**

### 1. 读取 PRD
- 从 `.claude/prds/$ARGUMENTS.md` 加载 PRD
- 分析所有需求和约束
- 理解用户故事和成功标准
- 从 frontmatter 中提取 PRD 描述

### 2. 技术分析
- 确定所需的架构决策
- 确定技术栈和方法
- 将功能需求映射到技术组件
- 识别集成点和依赖项

### 3. 带有 Frontmatter 的文件格式
在以下位置创建 epic 文件：`.claude/epics/$ARGUMENTS/epic.md`，格式如下：

```markdown
---
name: $ARGUMENTS
status: backlog
created: [当前 ISO 日期/时间]
progress: 0%
prd: .claude/prds/$ARGUMENTS.md
github: [同步到 GitHub 时将更新]
---

# Epic: $ARGUMENTS

## 概述
实现方法的技术摘要

## 架构决策
- 关键技术决策和理由
- 技术选择
- 要使用的设计模式

## 技术方法
### 前端组件
- 所需的 UI 组件
- 状态管理方法
- 用户交互模式

### 后端服务
- 所需的 API 端点
- 数据模型和模式
- 业务逻辑组件

### 基础设施
- 部署考虑
- 扩展需求
- 监控和可观察性

## 实现策略
- 开发阶段
- 风险缓解
- 测试方法

## 任务分解预览
将要创建的高级任务类别：
- [ ] 类别 1: 描述
- [ ] 类别 2: 描述
- [ ] 等等。

## 依赖项
- 外部服务依赖
- 内部团队依赖
- 先决条件工作

## 成功标准（技术）
- 性能基准
- 质量门禁
- 验收标准

## 估计工作量
- 总体时间估算
- 资源需求
- 关键路径项目
```

### 4. Frontmatter 指南
- **name**：使用确切的功能名称（与 $ARGUMENTS 相同）
- **status**：新 epic 始终以 "backlog" 开始
- **created**：通过运行获取真实的当前日期时间：`date -u +"%Y-%m-%dT%H:%M:%SZ"`
- **progress**：新 epic 始终以 "0%" 开始
- **prd**：引用源 PRD 文件路径
- **github**：保留占位符文本 - 将在同步期间更新

### 5. 输出位置
如果不存在则创建目录结构：
- `.claude/epics/$ARGUMENTS/`（目录）
- `.claude/epics/$ARGUMENTS/epic.md`（epic 文件）

### 6. 质量验证

在保存 epic 之前，请验证：
- [ ] 所有 PRD 需求都在技术方法中得到解决
- [ ] 任务分解类别涵盖所有实现领域
- [ ] 依赖项在技术上准确
- [ ] 工作量估算是现实的
- [ ] 架构决策是合理的

### 7. 创建后

成功创建 epic 后：
1. 确认："✅ Epic 已创建：.claude/epics/$ARGUMENTS/epic.md"
2. 显示摘要：
   - 识别的任务类别数量
   - 关键架构决策
   - 估计工作量
3. 建议下一步："准备好分解为任务了吗？运行：/pm:epic-decompose $ARGUMENTS"

## 错误恢复

如果任何步骤失败：
- 清楚地解释出了什么问题
- 如果 PRD 不完整，列出具体的缺失章节
- 如果技术方法不明确，识别需要澄清的内容
- 永远不要创建信息不完整的 epic

专注于创建一个技术上合理且可实现的实现计划，该计划解决所有 PRD 需求，针对 "$ARGUMENTS"。

## 重要：
- 目标是尽可能少的任务，并将总任务数限制在 10 个或更少。
- 在创建 epic 时，找出简化和改进的方法。寻找利用现有功能而不是创建更多代码的方法。