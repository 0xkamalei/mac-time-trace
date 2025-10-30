# TimeVibe 架构设计

本文档描述 TimeVibe 应用的整体架构设计、核心组件和设计模式。

## 系统架构概览

```
┌─────────────────────────────────────────────────────────┐
│                     SwiftUI Views                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │ Sidebar  │  │ Timeline │  │ Activity │  │ Sheets  │ │
│  │   View   │  │   View   │  │   View   │  │  Views  │ │
│  └──────────┘  └──────────┘  └──────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                     AppState                             │
│              (Observable Object)                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ • Projects Hierarchy                             │   │
│  │ • Timer State                                    │   │
│  │ • Selection State                                │   │
│  │ • Sheet Presentation State                       │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    Managers Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Activity    │  │    Timer     │  │     Idle     │  │
│  │   Manager    │  │   Manager    │  │   Detector   │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                   SwiftData Layer                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │ Project  │  │ Activity │  │TimeEntry │              │
│  │  Model   │  │  Model   │  │  Model   │              │
│  └──────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│              System Integration Layer                    │
│  ┌──────────────────────────────────────────────────┐  │
│  │ NSWorkspace Notifications                         │  │
│  │ • didActivateApplicationNotification              │  │
│  │ • willSleepNotification                           │  │
│  │ • didWakeNotification                             │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## 核心组件

### 1. 视图层 (Views)

#### NavigationSplitView
- 主应用布局
- 三栏结构：侧边栏、内容区、详情区（可选）

#### SidebarView
- 项目层级导航
- 支持拖拽重排序
- 显示项目总时间

#### TimelineView
- 核心可视化组件
- 三行显示：设备活动、项目、时间条目
- 支持缩放和交互

#### ActivityView
- 活动列表和统计
- 多级分组和折叠
- 时间范围筛选

### 2. 状态管理层

#### AppState (ObservableObject)
**职责**:
- 作为应用的单一数据源
- 管理项目层级结构
- 维护计时器状态
- 协调视图间的状态同步

**关键属性**:
```swift
@Published var projects: [Project]
@Published var selectedProjectId: UUID?
@Published var isTimerActive: Bool
@Published var activeTimerProject: Project?
```

**设计模式**: 单例模式 + 观察者模式

### 3. 业务逻辑层 (Managers)

#### ActivityManager
**职责**:
- 追踪应用切换事件
- 记录活动数据
- 处理系统睡眠/唤醒事件

**关键方法**:
```swift
func trackAppSwitch(newApp: String, modelContext: ModelContext)
func stopTrack(modelContext: ModelContext)
func handleSystemWake()
```

#### TimerManager
**职责**:
- 管理计时器会话
- 处理计时器启动/停止
- 生成时间条目

**关键方法**:
```swift
func startTimer(for project: Project)
func stopTimer() -> TimeEntry?
func restoreActiveSession()
```

#### IdleDetector
**职责**:
- 检测用户空闲时间
- 触发空闲恢复对话框
- 处理空闲时间分配

### 4. 数据模型层

#### Project
```swift
@Model
class Project {
    var id: UUID
    var title: String
    var color: Data  // Color encoded
    var parentId: UUID?
    var children: [Project]
    var order: Int
}
```

#### Activity
```swift
@Model
class Activity {
    var id: UUID
    var appBundleId: String
    var appName: String
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval
}
```

#### TimeEntry
```swift
@Model
class TimeEntry {
    var id: UUID
    var projectId: UUID
    var title: String?
    var notes: String?
    var startTime: Date
    var endTime: Date
    var activities: [Activity]
}
```

### 5. 系统集成层

#### NSWorkspace 通知监听
- **didActivateApplicationNotification**: 应用激活时触发
- **willSleepNotification**: 系统睡眠前触发
- **didWakeNotification**: 系统唤醒后触发
- **didDeactivateApplicationNotification**: 应用失去焦点时触发

## 数据流

### 活动追踪流程

```
用户切换应用
    │
    ▼
NSWorkspace 发送通知
    │
    ▼
ActivityManager.trackAppSwitch()
    │
    ├─> 保存前一个应用的活动
    │   └─> SwiftData 持久化
    │
    └─> 开始追踪新应用
        └─> 更新当前活动状态
```

### 时间条目创建流程

```
用户点击 "Start Timer"
    │
    ▼
TimerManager.startTimer()
    │
    ├─> 更新 AppState.isTimerActive
    │
    └─> 记录开始时间和项目
        │
        ▼
用户点击 "Stop Timer"
    │
    ▼
TimerManager.stopTimer()
    │
    ├─> 计算持续时间
    │
    ├─> 创建 TimeEntry
    │
    └─> SwiftData 持久化
```

### 项目层级管理流程

```
用户在 UI 中拖拽项目
    │
    ▼
SidebarView 更新 order
    │
    ▼
AppState.reorderProjects()
    │
    └─> 更新所有项目的 order 属性
        │
        ▼
    SwiftData 自动持久化
        │
        ▼
    视图自动刷新 (@Published)
```

## 设计模式

### 1. MVVM (Model-View-ViewModel)
- **Model**: SwiftData 模型 (Project, Activity, TimeEntry)
- **View**: SwiftUI 视图
- **ViewModel**: AppState 和各种 Manager

### 2. 单例模式
- ActivityManager.shared
- TimerManager.shared
- 确保全局唯一实例

### 3. 观察者模式
- SwiftUI 的 @Published 和 @ObservedObject
- 自动视图更新机制

### 4. 策略模式
- 不同的活动分组策略
- 可配置的空闲检测策略

## 性能优化

### 1. 数据加载
- 使用 SwiftData 的懒加载
- 分页加载大量时间条目
- 缓存计算结果

### 2. 视图渲染
- 使用 `#Preview` 进行快速迭代
- 避免不必要的视图重绘
- 优化列表性能（LazyVStack）

### 3. 后台处理
- 活动追踪在后台线程
- 使用 Task 和 @MainActor 管理并发

## 扩展性考虑

### 1. 多设备同步
- 预留 deviceId 字段
- 使用 CloudKit 或自定义同步服务

### 2. 插件系统
- 规则引擎可扩展
- 支持自定义活动处理器

### 3. 导出/导入
- 标准化数据格式
- 支持多种导出格式（CSV, JSON）

## 安全性

### 1. 数据加密
- 敏感数据加密存储
- 使用 Keychain 存储凭证

### 2. 权限管理
- 请求必要的系统权限
- 辅助功能权限用于应用追踪

### 3. 隐私保护
- 本地优先存储
- 可选的云同步
- 用户数据完全控制

## 测试策略

### 1. 单元测试
- 业务逻辑测试（Managers）
- 数据模型测试
- 工具函数测试

### 2. 集成测试
- 数据流测试
- 状态管理测试

### 3. UI 测试
- 关键用户流程测试
- 视图交互测试

## 未来改进方向

1. **完善 SwiftData 集成** - 从模拟数据迁移到完整持久化
2. **实现规则引擎** - 自动项目分配
3. **增强报告功能** - 更丰富的统计和可视化
4. **多设备同步** - CloudKit 集成
5. **性能优化** - 大数据集处理优化
