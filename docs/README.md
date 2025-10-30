# TimeVibe 文档中心

欢迎来到 TimeVibe 项目文档。本目录包含所有项目相关的技术文档。

## 📚 文档导航

### 核心文档

- **[DEVELOPMENT.md](DEVELOPMENT.md)** - 开发指南和技术规范
  - 项目概览和架构
  - 功能特性详解
  - 开发命令和工作流
  - 数据模型和状态管理
  - AI 助手参考文档

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - 系统架构设计
  - 架构概览图
  - 核心组件说明
  - 数据流和设计模式
  - 性能优化策略
  - 扩展性考虑

### 项目管理

- **[TODO.md](TODO.md)** - 功能开发计划
  - 待实现功能列表
  - 优先级分类
  - 实施阶段规划

- **[BUG_REPORT.md](BUG_REPORT.md)** - 缺陷报告
  - 已知问题列表
  - 问题分类和优先级
  - 修复建议

### 产品文档

- **[Timing App PRD.markdown](Timing%20App%20PRD.markdown)** - 产品需求文档
  - 产品定位和目标
  - 功能需求详解
  - 用户故事

### AI 提示词

- **[ai-prompts/](ai-prompts/)** - AI 助手提示词目录
  - `CODE.md` - 代码示例和模式
  - `SPEC.md` - 项目规范
  - `timing.md` - Timing 相关说明

## 🔗 符号链接

为了兼容不同 AI 助手的配置文件位置，我们使用符号链接：

- `/CLAUDE.md` → `docs/DEVELOPMENT.md`
- `/GEMINI.md` → `docs/DEVELOPMENT.md`
- `/.github/copilot-instructions.md` → `docs/DEVELOPMENT.md`

这确保了文档的单一数据源，避免重复维护。

## 📝 文档更新指南

### 更新开发文档

所有开发相关的文档更新应该在 `docs/DEVELOPMENT.md` 中进行。由于符号链接的存在，更新会自动反映到所有 AI 助手配置文件中。

### 添加新文档

1. 在 `docs/` 目录下创建新的 Markdown 文件
2. 在本 README 中添加链接
3. 如果是重要文档，考虑在主 README 中也添加引用

### 文档规范

- 使用 Markdown 格式
- 包含清晰的标题层级
- 添加代码示例时使用语法高亮
- 保持文档简洁和最新

## 🎯 快速查找

| 我想了解... | 查看文档 |
|------------|---------|
| 如何开始开发 | [DEVELOPMENT.md](DEVELOPMENT.md) |
| 系统架构设计 | [ARCHITECTURE.md](ARCHITECTURE.md) |
| 待实现功能 | [TODO.md](TODO.md) |
| 已知问题 | [BUG_REPORT.md](BUG_REPORT.md) |
| 产品需求 | [Timing App PRD.markdown](Timing%20App%20PRD.markdown) |
| 项目概览 | [../README.md](../README.md) |

## 💡 贡献文档

欢迎改进文档！请遵循以下原则：

1. **准确性** - 确保信息准确且最新
2. **清晰性** - 使用简洁明了的语言
3. **完整性** - 提供足够的上下文和示例
4. **一致性** - 遵循现有文档的格式和风格

---

最后更新：2025-10-30
