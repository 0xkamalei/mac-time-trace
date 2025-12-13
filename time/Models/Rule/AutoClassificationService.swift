import Foundation
import SwiftData
import os

class AutoClassificationService {
    static let shared = AutoClassificationService()
    
    // In-memory cache of rules for performance
    private var rules: [Rule] = []
    
    private let logger = Logger(subsystem: "com.time.vscode", category: "AutoClassification")
    
    private init() {}
    
    // MARK: - Rule Management
    
    @MainActor
    func loadRules(modelContext: ModelContext) {
        do {
            let descriptor = FetchDescriptor<Rule>(sortBy: [SortDescriptor(\.priority, order: .reverse)])
            self.rules = try modelContext.fetch(descriptor)
            logger.info("Loaded \(self.rules.count) classification rules")
        } catch {
            logger.error("Failed to load rules: \(error)")
        }
    }
    
    @MainActor
    func refreshRules(modelContext: ModelContext) {
        loadRules(modelContext: modelContext)
    }
    
    // MARK: - Classification
    
    /// Determines the project ID for an activity based on active rules
    /// - Parameter activity: The activity to classify
    /// - Returns: Project ID if a matching rule is found, otherwise nil
    func classify(activity: Activity) -> String? {
        for rule in rules where rule.isActive {
            if matches(activity: activity, rule: rule) {
                return rule.projectId
            }
        }
        return nil
    }
    
    private func matches(activity: Activity, rule: Rule) -> Bool {
        // App Name Check
        if let ruleAppName = rule.appName, !ruleAppName.isEmpty {
            // Check bundle ID or display name
            let matchesBundle = activity.appBundleId.localizedCaseInsensitiveContains(ruleAppName)
            let matchesName = activity.appName.localizedCaseInsensitiveContains(ruleAppName)
            
            if !matchesBundle && !matchesName {
                return false
            }
        }
        
        // Window Title Check
        if let pattern = rule.windowTitlePattern, !pattern.isEmpty {
            guard let title = activity.appTitle else { return false }
            
            // Try Regex
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                let range = NSRange(location: 0, length: title.utf16.count)
                if regex.firstMatch(in: title, options: [], range: range) != nil {
                     return true
                }
            } catch {
                // Not a valid regex, treat as simple substring match fallback
            }
            
            // Simple string match
            if !title.localizedCaseInsensitiveContains(pattern) {
                return false
            }
        }
        
        return true
    }
}
