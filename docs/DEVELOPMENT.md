# TimeVibe 开发文档

本文档为 AI 助手（Claude、Gemini、GitHub Copilot）和开发者提供项目的详细技术规范和开发指南。

## 项目概览

这是一个原生 macOS 时间跟踪应用，使用 SwiftUI 和 SwiftData 构建。类似 Timing.app，应用追踪应用使用情况，管理分层项目，并提供专注工作会话的计时器功能。

## 开发命令

### 构建和运行

```bash
# 构建项目
xcodebuild -project time.xcodeproj -scheme time -configuration Debug build

# 发布版本构建
xcodebuild -project time.xcodeproj -scheme time -configuration Release build

# 在 Xcode 中打开
open time.xcodeproj
```

### 常见开发任务

- 使用 Xcode 内置模拟器测试应用
- 应用目标为 macOS，最低部署目标在项目设置中定义
- 大多数视图使用 `#Preview` 支持 SwiftUI 预览

## 架构

### 代码风格

- 使用 SwiftUI 和 SwiftData 的最新版本和最佳实践

### 功能特性

#### Project（项目）

- 项目支持层级结构，允许在项目下添加子项目
- 创建项目、"新建时间条目"或"启动计时器"时，可以快速添加子项目
- 在左侧边栏显示项目树，可以通过拖拽改变项目的显示顺序
- 点击左侧边栏中的项目进行选择，当前项目成为"所有活动"查询的筛选条件
- `project.title` 是项目下的具体任务；例如，如果项目是开发 timing.app，`project.title` 会是编写 PRD
- "未分配"代表尚未通过时间条目分配到项目的活动；可以选择"未分配"来仅筛选未分配的活动
- "所有活动"代表不按项目筛选；选中时，"未分配"应显示在详情顶部
- "我的项目"等同于查询所有分配给项目的活动
- 当选中项目但没有对应活动时，显示"No time traced"
- 在侧边栏每个项目末尾，显示该项目对应活动的总时间

#### Activity（活动）

- 打开程序后自动记录活动，目前正在实现中
- 活动基于应用切换事件自动记录前一个应用占用的时间
- 活动显示结果可以通过各种条件筛选：时间范围、项目
- 活动详情显示分为两栏：一栏用于摘要，一栏用于分组显示；默认按项目、project.title、activity.title 分组
- 活动显示逻辑是多级可折叠列表：项目 -> 子项目（如有）-> 标题（在 timeEntry 中填写，未分配则无标题）-> 时间段 -> 应用图标和名称 -> app.title（相同标题的活动聚合在一起）-> 活动应用使用详情 开始时间 ~ 结束时间

#### Time Entry（时间条目）

- 时间分配功能，将活动分配到对应的项目或子项目
- time-entry 可以手动通过"New Time Entry"添加，也可以通过"Start timer"/"Stop Timer"生成
- 对于没有分配 time-entry 的时间，在 timeline 组件中会显示推荐添加的按钮

#### Project、Activity、Time-Entry 的关系

- activity 是所有自动记录的应用使用时间事件，在 timeline 组件中 device 一列显示所有的 activities；使用时间越长占用的色块越长，比如 12:00～13:00 一直在使用 app A，则在时间轴上 12:00～13:00 显示这个 app A 的图标，图标居中显示，色块是根据 app 绑定的
- 所有记录的 time-entry 都有关联的 project；project 在 timeline 组件的第二行显示；time-entry 的 title 相当于 project 的具体活动
- time-entry 在 timeline 组件第三行显示

#### TimePicker（时间选择器）

- timepicker 组件允许快速选择时间范围，仅支持日期选择
- 使用快速时间选择时，两个对应的日期选择器会实时计算和改变，并立即用于筛选数据

#### Timeline（时间线）

- 这是应用的核心功能，用于显示应用使用、项目状态和 project.title 状态的概览
- 可用于显示项目和活动，也可用于快速滑动选择时间范围，以及快速添加时间条目
- timeline 部分可以通过按住 cmd+鼠标滚轮进行缩放
- Timeline 由三行组成：
  - Timeline 第一行显示当前设备活动，显示为应用图标；缩放时，显示该时间段内使用最多的应用图标；鼠标悬停在图标上显示详细信息
  - Timeline 第二行显示项目色块
  - Timeline 第三行显示时间条目；如果未分配，显示添加图标按钮，点击按钮弹出"New time entry"，start-time 和 end-time 自动填充在表单中
- 鼠标悬浮在 timeline 上时显示这个时间的具体信息，包括对应时间 project 的信息、activity 的信息、time-entry 的信息（如果有）

#### Background（后台追踪）

- 通过 `didActivateApplicationNotification` 获取应用激活通知
- 激活后，调用 `ActivityManager.trackAppSwitch` 代码示例：

```swift
NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { notification in
    print("Event didActivateApplicationNotification")
    // 在这里执行你的回调操作
    if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
        print(app.bundleIdentifier ?? "-")
        Task {
            @MainActor in
            ActivityManager.shared.trackAppSwitch(newApp: app.bundleIdentifier ?? "-", modelContext: modelContext)
        }
    }
}

NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { _ in
    print("Event willSleepNotification")
    Task {
        @MainActor in
        ActivityManager.shared.stopTrack(modelContext: modelContext)
    }
}
```

### APP 追踪实现逻辑

监听 `didActivateApplicationNotification` 和 `willSleepNotification` 事件，通过 ActivityManager 维护状态。如果应用切换，保存前一个应用的活动。如果系统进入睡眠，直接保存当前应用状态。

必须能够获取应用的图标以供显示使用。

### Activity 统计逻辑

基于每个活动的结束时间减去开始时间计算持续时间，合并持续时间以获得使用时间。可以根据分组分别计算每组的时间。例如，如果按项目分组，可以根据持续时间计算每个项目的总时间。

### 状态管理

- **AppState**: 中央 `ObservableObject` 管理全局应用状态
  - 具有父/子关系的项目层级
  - 计时器状态和活动追踪
  - 通过基于索引的系统重新排序项目
- 项目在内存中管理，计划集成 SwiftData

### 数据模型

- **Project**: 分层项目结构，带有颜色编码，自定义 Color 持久化的编码/解码
- **Activity**: 表示应用使用追踪，包含持续时间、系统图标和应用 ID
- **TimeEntry**: 对应项目下的工作时段，由用户通过按钮启动和结束；也可以根据配置在待机期间由系统自动停止

### 视图架构

- **NavigationSplitView**: 带有侧边栏和详情视图的主布局
- **SidebarView**: 项目导航，带有可展开/折叠的部分
- **Modular Views**: 用于编辑项目、时间条目和计时器控制的独立视图
- **Sheet Presentations**: 用于添加项目和时间条目的模态对话框

### 关键文件

- `AppState.swift`: 中央状态管理和项目层级逻辑
- `Models/Project.swift`: 项目模型，带有颜色编码和层级支持
- `Views/SidebarView.swift`: 项目导航和选择
- `ContentView.swift`: 主应用布局和 sheet 协调

## 开发注意事项

### 项目管理

- 在更新文件前使用 git commit 保存所有更改
- 目前使用模拟数据进行开发和测试

### 状态流

- AppState 作为项目数据的单一数据源
- Published 属性自动更新 SwiftUI 视图
- 计时器状态集中管理以确保视图间的一致性
- Sheet 展示状态在 ContentView 中管理以协调模态对话框

### UI 模式

- 颜色编码的项目用于视觉组织
- 用于可展开项目层级的 Disclosure groups
- NavigationLink 和选择绑定用于侧边栏导航
