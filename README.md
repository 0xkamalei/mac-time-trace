# TimeVibe

一个原生 macOS 时间跟踪应用，使用 SwiftUI 和 SwiftData 构建。类似 Timing.app，自动追踪应用使用情况，管理分层项目，并提供专注工作会话的计时器功能。

## ✨ 主要功能

- **自动活动追踪** - 自动记录应用使用时间和切换事件
- **分层项目管理** - 支持项目和子项目的层级结构
- **时间条目管理** - 手动添加或通过计时器生成时间条目
- **交互式时间线** - 可视化展示应用使用、项目状态和时间分配
- **规则引擎** - 基于规则自动分配活动到项目
- **统计报告** - 详细的时间统计和生产力分析

## 🚀 快速开始

### 环境要求

- macOS 13.0+
- Xcode 15.0+
- Swift 5.9+

### 构建和运行

```bash
# 在 Xcode 中打开项目
open time.xcodeproj

# 或使用命令行构建
xcodebuild -project time.xcodeproj -scheme time -configuration Debug build
```

### 运行测试

```bash
./scripts/run_tests.sh
```

## 📁 项目结构

```
time-vibe/
├── time/                   # 主应用代码
│   ├── Models/            # 数据模型 (Project, Activity, TimeEntry)
│   ├── Views/             # SwiftUI 视图
│   ├── Managers/          # 业务逻辑管理器
│   └── Utils/             # 工具类
├── timeTests/             # 单元测试
├── timeUITests/           # UI 测试
├── landing/               # 落地页
├── docs/                  # 项目文档
└── scripts/               # 实用脚本
```

## 📖 文档

- [开发指南](docs/DEVELOPMENT.md) - 详细的开发文档和架构说明
- [架构设计](docs/ARCHITECTURE.md) - 系统架构和设计模式
- [待办事项](docs/TODO.md) - 功能开发计划
- [缺陷报告](docs/BUG_REPORT.md) - 已知问题和修复计划

## 🏗️ 核心架构

### 数据模型

- **Project** - 分层项目结构，支持颜色编码
- **Activity** - 应用使用追踪记录
- **TimeEntry** - 工作时间段，关联到项目

### 状态管理

- **AppState** - 中央状态管理，作为单一数据源
- **ActivityManager** - 活动追踪和系统事件处理
- **TimerManager** - 计时器状态和会话管理

### 视图架构

- **NavigationSplitView** - 侧边栏和详情视图的主布局
- **Timeline** - 核心时间线可视化组件
- **Modular Views** - 模块化的项目、时间条目编辑视图

## 🔧 开发

### 代码风格

- 使用 SwiftUI 和 SwiftData 最佳实践
- 遵循 Swift API 设计指南
- 所有视图支持 `#Preview` 预览

### Git 工作流

- 在修改文件前使用 `git commit` 保存所有更改
- 使用描述性的提交信息
- 功能开发在独立分支进行

### 测试

```bash
# 运行所有测试
./scripts/run_tests.sh

# 在 Xcode 中运行测试
⌘ + U
```

## 🤝 贡献

欢迎贡献！请查看 [开发指南](docs/DEVELOPMENT.md) 了解详细信息。

## 📄 许可证

[待添加许可证信息]

## 🔗 相关链接

- [落地页](landing/README.md)
- [AI 提示词](docs/ai-prompts/)

---

**注意**: 此项目目前处于活跃开发阶段，某些功能可能尚未完全实现。查看 [TODO](docs/TODO.md) 了解开发进度。
