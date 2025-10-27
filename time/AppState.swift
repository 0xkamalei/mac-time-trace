import SwiftData
import SwiftUI

import os

@MainActor
class AppState: ObservableObject {
    @Published var isTimerActive: Bool = false

    @Published var selectedProject: Project?
    @Published var selectedSidebar: String? = "All Activities"

    init() {
        selectedSidebar = "All Activities"
        selectedProject = nil

        setupNotificationObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Sets up notification observers for project change events
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProjectChange(_:)),
            name: .projectDidChange,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProjectDeleted(_:)),
            name: .projectWasDeleted,
            object: nil
        )
    }

    // MARK: - Selection Management

    /// 选择特殊项目（All Activities, Unassigned, My Projects）
    func selectSpecialItem(_ item: String) {
        withAnimation(.easeInOut(duration: 0.1)) {
            selectedProject = nil
            selectedSidebar = item
        }

        Logger.appState.info("Selected special item: \(item, privacy: .public)")

        switch item {
        case "All Activities":
            Logger.appState.info("Filtering mode: Show all activities")
        case "Unassigned":
            Logger.appState.info("Filtering mode: Show unassigned activities")
        case "My Projects":
            Logger.appState.info("Filtering mode: Show project activities")
        default:
            break
        }
    }

    /// 选择项目
    func selectProject(_ project: Project) {
        withAnimation(.easeInOut(duration: 0.1)) {
            selectedSidebar = nil
            selectedProject = project
        }

        Logger.appState.info("Selected project: \(project.name, privacy: .public)")
        Logger.appState.debug("Project ID: \(project.id, privacy: .public)")
        if let parentID = project.parentID {
            Logger.appState.debug("Parent project ID: \(parentID, privacy: .public)")
        }
        Logger.appState.debug("Project color: \(String(describing: project.color), privacy: .public)")
        Logger.appState.info("Applying project filter: \(project.name, privacy: .public)")

        // Notify through NotificationCenter instead of direct manager dependency
        NotificationCenter.default.post(
            name: .projectSelectionChanged,
            object: nil,
            userInfo: ["project": project]
        )
    }

    /// 清除所有选择
    func clearSelection() {
        withAnimation(.easeInOut(duration: 0.1)) {
            selectedProject = nil
            selectedSidebar = nil
        }

        // Notify through NotificationCenter
        NotificationCenter.default.post(
            name: .projectSelectionChanged,
            object: nil,
            userInfo: [:]
        )
    }

    /// Handles graceful selection when a project is deleted
    private func handleDeletedProjectSelection() {
        Logger.appState.notice("Handling deleted project selection, reverting to All Activities")
        selectSpecialItem("All Activities")
    }

    /// Validates current selection and handles deleted projects
    /// Should be called when receiving project deletion notifications
    private func validateCurrentSelection() {
        // This will be handled by notification observers
    }

    /// 检查是否选择了特定的特殊项目
    func isSpecialItemSelected(_ item: String) -> Bool {
        return selectedSidebar == item && selectedProject == nil
    }

    /// 检查是否选择了特定的项目
    func isProjectSelected(_ project: Project) -> Bool {
        return selectedProject?.id == project.id && selectedSidebar == nil
    }

    // MARK: - Notification Handlers

    /// Handles project change notifications from ProjectManager
    /// - Parameter notification: The notification containing project change information
    @objc private func handleProjectChange(_ notification: Notification) {
        validateCurrentSelection()

        if let userInfo = notification.userInfo,
           let projectCount = userInfo["projectCount"] as? Int,
           let timestamp = userInfo["timestamp"] as? Date
        {
            Logger.appState.debug("AppState received project change notification: \(projectCount) projects at \(timestamp, privacy: .public)")
        }
    }

    /// Handles project deletion notifications from ProjectManager
    /// - Parameter notification: The notification containing deleted project information
    @objc private func handleProjectDeleted(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let deletedProjectId = userInfo["projectId"] as? String,
           selectedProject?.id == deletedProjectId
        {
            Logger.appState.notice("Selected project was deleted, clearing selection")
            clearSelection()
        }
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let projectSelectionChanged = Notification.Name("projectSelectionChanged")
    static let projectDidChange = Notification.Name("projectDidChange")
    static let projectOperationFailed = Notification.Name("projectOperationFailed")
    static let projectWasDeleted = Notification.Name("projectWasDeleted")
    static let timerDidStop = Notification.Name("timerDidStop")
}
