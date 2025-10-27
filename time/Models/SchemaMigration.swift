import Foundation
import SwiftData
import os

/// Schema migration utility for handling data model evolution
class SchemaMigration {
    private static let logger = Logger(subsystem: "com.time.vscode", category: "SchemaMigration")
    private static let currentSchemaVersion = "1.0.0"
    private static let schemaVersionKey = "SchemaVersion"
    
    /// Performs migration from MockData to SwiftData models if needed
    static func performMigrationIfNeeded(modelContext: ModelContext) {
        let currentVersion = getCurrentSchemaVersion()
        logger.info("Current schema version: \(currentVersion ?? "none")")
        
        if shouldPerformMigration(currentVersion: currentVersion) {
            logger.info("Starting schema migration...")
            do {
                try migrateFromMockData(modelContext: modelContext)
                setSchemaVersion(currentSchemaVersion)
                logger.info("Schema migration completed successfully")
            } catch {
                logger.error("Schema migration failed: \(error.localizedDescription)")
                handleMigrationFailure(error: error)
            }
        } else {
            logger.info("No migration needed")
        }
        
        validateDataIntegrity(modelContext: modelContext)
    }
    
    /// Checks if migration is needed based on current version
    private static func shouldPerformMigration(currentVersion: String?) -> Bool {
        guard let currentVersion = currentVersion else {
            return hasExistingData()
        }
        
        return currentVersion != currentSchemaVersion
    }
    
    /// Checks if there's existing data that might need migration
    private static func hasExistingData() -> Bool {
        return false // For now, assume fresh installs don't need migration
    }
    
    /// Migrates data from MockData structure to SwiftData models
    private static func migrateFromMockData(modelContext: ModelContext) throws {
        logger.info("Migrating MockData to SwiftData models...")
        
        let existingActivities = try fetchExistingActivities(modelContext: modelContext)
        if !existingActivities.isEmpty {
            logger.info("Activities already exist, skipping MockData migration")
            return
        }
        
        var migratedCount = 0
        for mockActivity in MockData.activities {
            let activity = Activity(
                appName: mockActivity.appName,
                appBundleId: mockActivity.appBundleId,
                appTitle: mockActivity.appTitle,
                duration: mockActivity.duration,
                startTime: mockActivity.startTime,
                endTime: mockActivity.endTime,
                icon: mockActivity.icon
            )
            
            modelContext.insert(activity)
            migratedCount += 1
        }
        
        try modelContext.save()
        logger.info("Successfully migrated \(migratedCount) activities from MockData")
    }
    
    /// Fetches existing activities to check for duplicates
    private static func fetchExistingActivities(modelContext: ModelContext) throws -> [Activity] {
        let descriptor = FetchDescriptor<Activity>()
        return try modelContext.fetch(descriptor)
    }
    
    /// Validates data integrity after migration or startup
    private static func validateDataIntegrity(modelContext: ModelContext) {
        logger.info("Validating data integrity...")
        
        do {
            let activities = try fetchExistingActivities(modelContext: modelContext)
            var validationErrors: [String] = []
            
            let activeActivities = activities.filter { $0.endTime == nil }
            if activeActivities.count > 1 {
                validationErrors.append("Multiple active activities found: \(activeActivities.count)")
                fixMultipleActiveActivities(activities: activeActivities, modelContext: modelContext)
            }
            
            for activity in activities {
                if let endTime = activity.endTime, endTime < activity.startTime {
                    validationErrors.append("Invalid time range for activity \(activity.id): endTime before startTime")
                }
                
                if activity.appBundleId.isEmpty {
                    validationErrors.append("Empty bundle ID for activity \(activity.id)")
                }
            }
            
            if validationErrors.isEmpty {
                logger.info("Data integrity validation passed")
            } else {
                logger.warning("Data integrity issues found: \(validationErrors.joined(separator: ", "))")
            }
            
        } catch {
            logger.error("Data integrity validation failed: \(error.localizedDescription)")
        }
    }
    
    /// Fixes multiple active activities by setting endTime for all but the most recent
    private static func fixMultipleActiveActivities(activities: [Activity], modelContext: ModelContext) {
        let sortedActivities = activities.sorted { $0.startTime > $1.startTime }
        
        for (index, activity) in sortedActivities.enumerated() {
            if index > 0 { // Skip the first (most recent) activity
                activity.endTime = Date()
                activity.duration = activity.calculatedDuration
            }
        }
        
        do {
            try modelContext.save()
            logger.info("Fixed multiple active activities")
        } catch {
            logger.error("Failed to fix multiple active activities: \(error.localizedDescription)")
        }
    }
    
    /// Handles migration failure with fallback mechanisms
    private static func handleMigrationFailure(error: Error) {
        logger.error("Migration failed, implementing fallback strategy")
        
        
        UserDefaults.standard.set("failed", forKey: "MigrationStatus")
        UserDefaults.standard.set(error.localizedDescription, forKey: "MigrationError")
        
        logger.info("Continuing with empty database after migration failure")
    }
    
    /// Gets the current schema version from UserDefaults
    private static func getCurrentSchemaVersion() -> String? {
        return UserDefaults.standard.string(forKey: schemaVersionKey)
    }
    
    /// Sets the schema version in UserDefaults
    private static func setSchemaVersion(_ version: String) {
        UserDefaults.standard.set(version, forKey: schemaVersionKey)
        logger.info("Schema version set to: \(version)")
    }
    
    /// Clears migration status for testing purposes
    static func clearMigrationStatus() {
        UserDefaults.standard.removeObject(forKey: schemaVersionKey)
        UserDefaults.standard.removeObject(forKey: "MigrationStatus")
        UserDefaults.standard.removeObject(forKey: "MigrationError")
    }
}
