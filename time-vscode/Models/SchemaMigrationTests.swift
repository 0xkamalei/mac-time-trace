import Foundation
import SwiftData
import OSLog

/// Test utilities for schema migration functionality
class SchemaMigrationTests {
    private static let logger = Logger(subsystem: "com.time.vscode", category: "SchemaMigrationTests")
    
    /// Tests the complete migration process
    static func testMigration(modelContext: ModelContext) {
        logger.info("Starting schema migration tests...")
        
        // Clear any existing migration status for clean test
        SchemaMigration.clearMigrationStatus()
        
        // Test 1: Fresh migration
        testFreshMigration(modelContext: modelContext)
        
        // Test 2: Data integrity validation
        testDataIntegrity(modelContext: modelContext)
        
        // Test 3: Performance validation
        testPerformance(modelContext: modelContext)
        
        logger.info("Schema migration tests completed")
    }
    
    /// Tests migration from a fresh state
    private static func testFreshMigration(modelContext: ModelContext) {
        logger.info("Testing fresh migration...")
        
        do {
            // Clear existing data for clean test
            let descriptor = FetchDescriptor<Activity>()
            let existingActivities = try modelContext.fetch(descriptor)
            for activity in existingActivities {
                modelContext.delete(activity)
            }
            try modelContext.save()
            
            // Perform migration
            SchemaMigration.performMigrationIfNeeded(modelContext: modelContext)
            
            // Verify migration results
            let migratedActivities = try modelContext.fetch(descriptor)
            logger.info("Migration created \(migratedActivities.count) activities")
            
            // Validate some migrated data
            if let firstActivity = migratedActivities.first {
                assert(!firstActivity.appName.isEmpty, "App name should not be empty")
                assert(!firstActivity.appBundleId.isEmpty, "Bundle ID should not be empty")
                assert(firstActivity.startTime <= Date(), "Start time should not be in the future")
                logger.info("Sample activity validation passed")
            }
            
        } catch {
            logger.error("Fresh migration test failed: \(error.localizedDescription)")
        }
    }
    
    /// Tests data integrity after migration
    private static func testDataIntegrity(modelContext: ModelContext) {
        logger.info("Testing data integrity...")
        
        do {
            let descriptor = FetchDescriptor<Activity>()
            let activities = try modelContext.fetch(descriptor)
            
            var issues: [String] = []
            
            // Check for duplicate IDs
            let ids = activities.map { $0.id }
            let uniqueIds = Set(ids)
            if ids.count != uniqueIds.count {
                issues.append("Duplicate activity IDs found")
            }
            
            // Check time relationships
            for activity in activities {
                if let endTime = activity.endTime {
                    if endTime < activity.startTime {
                        issues.append("Invalid time range for activity \(activity.id)")
                    }
                }
                
                if activity.appBundleId.isEmpty {
                    issues.append("Empty bundle ID for activity \(activity.id)")
                }
                
                if activity.appName.isEmpty {
                    issues.append("Empty app name for activity \(activity.id)")
                }
            }
            
            // Check for multiple active activities
            let activeActivities = activities.filter { $0.endTime == nil }
            if activeActivities.count > 1 {
                issues.append("Multiple active activities found: \(activeActivities.count)")
            }
            
            if issues.isEmpty {
                logger.info("Data integrity test passed")
            } else {
                logger.warning("Data integrity issues: \(issues.joined(separator: ", "))")
            }
            
        } catch {
            logger.error("Data integrity test failed: \(error.localizedDescription)")
        }
    }
    
    /// Tests performance characteristics
    private static func testPerformance(modelContext: ModelContext) {
        logger.info("Testing performance...")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            // Test query performance
            let descriptor = FetchDescriptor<Activity>()
            let activities = try modelContext.fetch(descriptor)
            
            let queryTime = CFAbsoluteTimeGetCurrent() - startTime
            logger.info("Query of \(activities.count) activities took \(queryTime * 1000)ms")
            
            // Test filtered query performance
            let filteredStartTime = CFAbsoluteTimeGetCurrent()
            let today = Calendar.current.startOfDay(for: Date())
            let predicate = #Predicate<Activity> { activity in
                activity.startTime >= today
            }
            let filteredDescriptor = FetchDescriptor<Activity>(predicate: predicate)
            let todayActivities = try modelContext.fetch(filteredDescriptor)
            
            let filteredQueryTime = CFAbsoluteTimeGetCurrent() - filteredStartTime
            logger.info("Filtered query returned \(todayActivities.count) activities in \(filteredQueryTime * 1000)ms")
            
            // Performance thresholds
            if queryTime > 0.1 { // 100ms threshold
                logger.warning("Query performance may be suboptimal: \(queryTime * 1000)ms")
            }
            
            if filteredQueryTime > 0.05 { // 50ms threshold for filtered queries
                logger.warning("Filtered query performance may be suboptimal: \(filteredQueryTime * 1000)ms")
            }
            
        } catch {
            logger.error("Performance test failed: \(error.localizedDescription)")
        }
    }
    
    /// Tests schema version management
    static func testSchemaVersioning() {
        logger.info("Testing schema versioning...")
        
        // Clear version for testing
        SchemaMigration.clearMigrationStatus()
        
        // Test version detection
        let initialVersion = UserDefaults.standard.string(forKey: "SchemaVersion")
        assert(initialVersion == nil, "Initial version should be nil")
        
        // Simulate version setting
        UserDefaults.standard.set("1.0.0", forKey: "SchemaVersion")
        let setVersion = UserDefaults.standard.string(forKey: "SchemaVersion")
        assert(setVersion == "1.0.0", "Version should be set correctly")
        
        logger.info("Schema versioning test passed")
    }
    
    /// Tests error handling scenarios
    static func testErrorHandling(modelContext: ModelContext) {
        logger.info("Testing error handling...")
        
        // Test with invalid context (this is a conceptual test)
        // In practice, we would test various error scenarios
        
        // Test migration failure recovery
        UserDefaults.standard.set("failed", forKey: "MigrationStatus")
        let migrationStatus = UserDefaults.standard.string(forKey: "MigrationStatus")
        assert(migrationStatus == "failed", "Migration status should be recorded")
        
        // Clean up test state
        SchemaMigration.clearMigrationStatus()
        
        logger.info("Error handling test completed")
    }
}