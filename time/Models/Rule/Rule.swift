import Foundation
import SwiftData

@Model
final class Rule {
    @Attribute(.unique) var id: UUID
    var name: String
    var appName: String? // Specific app bundle ID or name, or nil for any
    var windowTitlePattern: String? // Regex or simple match string
    var projectId: String // Target project ID
    var priority: Int // Higher priority rules are checked first
    var isActive: Bool
    var createdAt: Date
    
    init(name: String, appName: String? = nil, windowTitlePattern: String? = nil, projectId: String, priority: Int = 0, isActive: Bool = true) {
        self.id = UUID()
        self.name = name
        self.appName = appName
        self.windowTitlePattern = windowTitlePattern
        self.projectId = projectId
        self.priority = priority
        self.isActive = isActive
        self.createdAt = Date()
    }
}
