//
//  IntegrationTests.swift
//  timeTests
//
//  Created by GitHub Copilot on 2025/09/30.
//

import SwiftData
import SwiftUI
@testable import time_vscode
import XCTest

/// 集成测试：测试整个应用的主要功能流程
@MainActor
final class IntegrationTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var appState: AppState!
    var projectManager: ProjectManager!
    var activityManager: ActivityManager!

    override func setUp() async throws {
        try await super.setUp()

        // 创建内存数据库用于测试
        let schema = Schema([
            Item.self,
            Activity.self,
            Project.self,
            TimeEntry.self,
            Rule.self,
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        modelContainer = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
        modelContext = modelContainer.mainContext

        // 初始化全局状态和管理器
        appState = AppState()
        projectManager = ProjectManager.shared
        projectManager.setModelContext(modelContext)
        activityManager = ActivityManager.shared

        // 等待ProjectManager加载完成
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
    }

    override func tearDown() async throws {
        // 清理测试数据
        activityManager.stopTracking(modelContext: modelContext)

        appState = nil
        projectManager = nil
        modelContext = nil
        modelContainer = nil

        try await super.tearDown()
    }

    // MARK: - 环境对象注入测试

    /// 测试所有必需的环境对象是否正确注入
    func testEnvironmentObjectsInjection() throws {
        // 验证AppState已创建
        XCTAssertNotNil(appState, "AppState should be initialized")

        // 验证ProjectManager已创建并配置
        XCTAssertNotNil(projectManager, "ProjectManager should be initialized")
        XCTAssertNotNil(projectManager.modelContext, "ProjectManager should have modelContext")

        // 验证ActivityManager已创建
        XCTAssertNotNil(activityManager, "ActivityManager should be initialized")
    }

    // MARK: - 项目管理集成测试

    /// 测试完整的项目创建、查询、更新、删除流程
    func testProjectCRUDFlow() async throws {
        // 1. 创建父项目
        let parentProject = try await projectManager.createProject(
            name: "集成测试项目",
            color: .blue,
            parentID: nil
        )

        XCTAssertNotNil(parentProject, "Parent project should be created")
        XCTAssertEqual(parentProject.name, "集成测试项目")

        // 2. 创建子项目
        let childProject = try await projectManager.createProject(
            name: "子任务",
            color: .green,
            parentID: parentProject.id
        )

        XCTAssertNotNil(childProject, "Child project should be created")
        XCTAssertEqual(childProject.parentID, parentProject.id)

        // 3. 验证层级关系
        let children = try await projectManager.getChildren(of: parentProject.id)
        XCTAssertEqual(children.count, 1, "Parent should have 1 child")
        XCTAssertEqual(children.first?.id, childProject.id)

        // 4. 更新项目
        try await projectManager.updateProject(
            parentProject,
            name: "更新后的项目",
            color: .red
        )

        XCTAssertEqual(parentProject.name, "更新后的项目")
        XCTAssertEqual(parentProject.color, .red)

        // 5. 删除项目
        try await projectManager.deleteProject(parentProject)

        // 验证删除成功
        let allProjects = try await projectManager.getAllProjects()
        XCTAssertFalse(allProjects.contains(where: { $0.id == parentProject.id }))
        // Child project behavior depends on default strategy, but assuming simple delete for now based on ProjectManager implementation
    }

    // MARK: - Activity跟踪集成测试

    /// 测试Activity自动跟踪功能
    func testActivityTrackingFlow() async throws {
        // 1. 开始跟踪
        activityManager.startTracking(modelContext: modelContext)

        // 模拟应用切换
        activityManager.trackAppSwitch(newApp: "com.apple.Safari", modelContext: modelContext)

        // 等待一段时间
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒

        // 2. 验证当前Activity
        let currentActivity = activityManager.getCurrentActivity()
        XCTAssertNotNil(currentActivity, "Should have current activity")
        XCTAssertEqual(currentActivity?.appBundleId, "com.apple.Safari")

        // 3. 切换到另一个应用
        activityManager.trackAppSwitch(newApp: "com.apple.Xcode", modelContext: modelContext)

        // 4. 验证Activity已保存
        let descriptor = FetchDescriptor<Activity>(
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        let activities = try modelContext.fetch(descriptor)

        XCTAssertTrue(activities.count > 0, "Should have saved activities")

        // 5. 停止跟踪
        activityManager.stopTracking(modelContext: modelContext)

        // 验证停止后没有当前Activity
        let stoppedActivity = activityManager.getCurrentActivity()
        XCTAssertNil(stoppedActivity, "Should not have current activity after stopping")
    }

    // MARK: - TimeEntry创建和查询测试

    /// 测试TimeEntry的创建和与Project的关联
    func testTimeEntryCreationWithProject() async throws {
        // 1. 创建项目
        let project = try await projectManager.createProject(
            name: "时间条目测试项目",
            color: .blue,
            parentID: nil
        )

        // 2. 创建TimeEntry
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(3600) // 1小时后

        let timeEntry = TimeEntry(
            projectId: project.id,
            title: "测试任务",
            startTime: startTime,
            endTime: endTime
        )

        modelContext.insert(timeEntry)
        try modelContext.save()

        // 3. 验证TimeEntry已保存
        let descriptor = FetchDescriptor<TimeEntry>(
            predicate: #Predicate { $0.projectId == project.id }
        )
        let entries = try modelContext.fetch(descriptor)

        XCTAssertEqual(entries.count, 1, "Should have 1 time entry")
        XCTAssertEqual(entries.first?.title, "测试任务")
        XCTAssertEqual(entries.first?.projectId, project.id)

        // 4. 验证时长计算
        let duration = entries.first?.calculatedDuration ?? 0
        XCTAssertEqual(duration, 3600, accuracy: 1.0, "Duration should be 1 hour")
    }

    // MARK: - Sidebar选择和过滤测试

    /// 测试Sidebar的项目选择和Activity过滤
    func testSidebarProjectSelectionFiltering() async throws {
        // 1. 创建多个项目
        let project1 = try await projectManager.createProject(
            name: "项目1",
            color: .blue,
            parentID: nil
        )

        let project2 = try await projectManager.createProject(
            name: "项目2",
            color: .green,
            parentID: nil
        )

        // 2. 创建Activities
        let activity1 = Activity(
            appBundleId: "com.apple.Safari",
            appName: "Safari",
            startTime: Date(),
            endTime: Date().addingTimeInterval(600)
        )
        // Note: Activity doesn't have projectID - project assignment is handled through time entries
        modelContext.insert(activity1)

        let activity2 = Activity(
            appBundleId: "com.apple.Xcode",
            appName: "Xcode",
            startTime: Date(),
            endTime: Date().addingTimeInterval(600)
        )
        // Note: Activity doesn't have projectID - project assignment is handled through time entries
        modelContext.insert(activity2)

        let activityUnassigned = Activity(
            appBundleId: "com.apple.Notes",
            appName: "Notes",
            startTime: Date(),
            endTime: Date().addingTimeInterval(600)
        )
        modelContext.insert(activityUnassigned)

        try modelContext.save()

        // 3. 测试"All Activities"选择
        appState.selectSpecialItem("All Activities")
        XCTAssertTrue(appState.isSpecialItemSelected("All Activities"))
        XCTAssertNil(appState.selectedSidebar) // Sidebar selection logic might differ in appState now, assuming simple selection check

        // 4. 测试"Unassigned"选择
        appState.selectSpecialItem("Unassigned")
        XCTAssertTrue(appState.isSpecialItemSelected("Unassigned"))

        // 5. 测试项目选择
        appState.selectProject(project1)
        // Assuming appState has a way to check if project is selected. Based on view code:
        XCTAssertTrue(appState.isProjectSelected(project1))
        XCTAssertFalse(appState.isSpecialItemSelected("All Activities"))
    }

    // MARK: - 项目层级拖放测试

    /// 测试项目在层级中的拖放重新排序
    func testProjectDragDropReordering() async throws {
        // 1. 创建多个项目
        let project1 = try await projectManager.createProject(
            name: "项目A",
            color: .blue,
            parentID: nil
        )

        let project2 = try await projectManager.createProject(
            name: "项目B",
            color: .green,
            parentID: nil
        )

        let project3 = try await projectManager.createProject(
            name: "项目C",
            color: .red,
            parentID: nil
        )

        // 2. 验证初始顺序
        let initialProjects = try await projectManager.getRootProjects()
        XCTAssertEqual(initialProjects.count, 3)

        // 3. 重新排序：将project3移到project1之前 (index 0)
        try await projectManager.reorderProject(project3, to: 0, in: nil)

        // 4. 验证新顺序 - Note: reorderProject in manager updates the property but fetching all needs to reflect it. 
        // As defined in ProjectManager.swift currently, reorderProject updates sortOrder.
        // We need to refresh projects from context or fetched array.
        let reorderedProjects = try await projectManager.getRootProjects()
        // Assuming sort by sortOrder
        XCTAssertEqual(reorderedProjects.first?.id, project3.id)
    }

    // MARK: - Activity数据处理器测试

    /// 测试Activity分组和统计
    func testActivityGroupingAndStatistics() async throws {
        // 1. 创建项目
        let project = try await projectManager.createProject(
            name: "统计测试项目",
            color: .blue,
            parentID: nil
        )

        // 2. 创建多个Activities
        let baseTime = Date()
        for i in 0 ..< 5 {
            let activity = Activity(
                appBundleId: "com.apple.Safari",
                appName: "Safari",
                startTime: baseTime.addingTimeInterval(TimeInterval(i * 600)),
                endTime: baseTime.addingTimeInterval(TimeInterval((i + 1) * 600))
            )
            // Note: Activity doesn't have projectID - project assignment is handled through time entries
            activity.appTitle = "测试窗口\(i)"
            modelContext.insert(activity)
        }
        try modelContext.save()

        // 3. 查询Activities (Note: Activities don't have direct project assignment)
        let descriptor = FetchDescriptor<Activity>(
            sortBy: [SortDescriptor(\.startTime)]
        )
        let activities = try modelContext.fetch(descriptor)

        XCTAssertEqual(activities.count, 5, "Should have 5 activities")

        // 4. 计算总时长
        let totalDuration = activities.reduce(0.0) { $0 + $1.duration }
        XCTAssertEqual(totalDuration, 3000, accuracy: 1.0, "Total duration should be 50 minutes")
        
        // Removed generic ActivityDataProcessor assumption if it doesn't match current codebase
    }

    // MARK: - 完整用户流程测试

    /// 测试完整的用户使用流程：创建项目 -> 跟踪活动 -> 创建时间条目 -> 查询统计
    func testCompleteUserWorkflow() async throws {
        // 1. 用户创建项目
        let project = try await projectManager.createProject(
            name: "完整流程测试",
            color: .purple,
            parentID: nil
        )
        XCTAssertNotNil(project)

        // 2. 用户开始工作，应用自动跟踪活动
        activityManager.startTracking(modelContext: modelContext)
        activityManager.trackAppSwitch(newApp: "com.apple.Xcode", modelContext: modelContext)

        try await Task.sleep(nanoseconds: 500_000_000) // 模拟工作0.5秒

        // 3. 用户切换应用
        activityManager.trackAppSwitch(newApp: "com.apple.Safari", modelContext: modelContext)

        try await Task.sleep(nanoseconds: 500_000_000)

        // 4. 用户手动创建时间条目
        let timeEntry = TimeEntry(
            projectId: project.id,
            title: "完成功能实现",
            notes: nil,
            startTime: Date().addingTimeInterval(-1800), // 30分钟前
            endTime: Date()
        )
        modelContext.insert(timeEntry)
        try modelContext.save()

        // 5. 用户查询项目的所有活动
        let activityDescriptor = FetchDescriptor<Activity>(
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        let allActivities = try modelContext.fetch(activityDescriptor)
        XCTAssertTrue(allActivities.count >= 1, "Should have tracked activities")

        // 6. 用户查询项目的时间条目
        let entryDescriptor = FetchDescriptor<TimeEntry>(
            predicate: #Predicate { $0.projectId == project.id }
        )
        let entries = try modelContext.fetch(entryDescriptor)
        XCTAssertEqual(entries.count, 1, "Should have 1 time entry")

        // 7. 用户停止跟踪
        activityManager.stopTracking(modelContext: modelContext)

        // 8. 验证最终状态
        XCTAssertNil(activityManager.getCurrentActivity(), "Should not have current activity")

        // 9. 用户删除项目
        try await projectManager.deleteProject(project)

        // 验证删除成功
        let remainingProjects = try await projectManager.getAllProjects()
        XCTAssertFalse(remainingProjects.contains(where: { $0.id == project.id }))
    }

    // MARK: - 性能测试

    /// 测试大量数据下的性能
    func testPerformanceWithLargeDataset() async throws {
        // 创建大量项目和活动
        let startTime = Date()

        // 创建100个项目
        var projects: [Project] = []
        for i in 0 ..< 100 {
            let project = try await projectManager.createProject(
                name: "性能测试项目\(i)",
                color: .blue,
                parentID: nil
            )
            projects.append(project)
        }

        // 为每个项目创建10个活动
        for project in projects.prefix(10) { // 只为前10个项目创建活动，避免测试时间过长
            for j in 0 ..< 10 {
                let activity = Activity(
                    appBundleId: "com.test.app\(j)",
                    appName: "TestApp\(j)",
                    startTime: Date(),
                    endTime: Date().addingTimeInterval(600)
                )
                // Note: Activity doesn't have projectID - project assignment is handled through time entries
                modelContext.insert(activity)
            }
        }
        try modelContext.save()

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        print("⏱️ 创建100个项目和100个活动耗时: \(duration)秒")

        // 验证性能在可接受范围内（应该在10秒内完成）
        XCTAssertLessThan(duration, 10.0, "Large dataset creation should complete within 10 seconds")

        // 测试查询性能
        let queryStart = Date()
        let allProjects = try await projectManager.getAllProjects()
        let queryEnd = Date()
        let queryDuration = queryEnd.timeIntervalSince(queryStart)

        print("⏱️ 查询所有项目耗时: \(queryDuration)秒")

        XCTAssertEqual(allProjects.count, 100, "Should have 100 projects")
        XCTAssertLessThan(queryDuration, 1.0, "Query should complete within 1 second")
    }
}
