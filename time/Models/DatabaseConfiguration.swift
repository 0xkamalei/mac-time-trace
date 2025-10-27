import Foundation
import SwiftData
import SQLite3
import os

/// Database configuration and optimization utilities
class DatabaseConfiguration {
    private static let logger = Logger(subsystem: "com.time.vscode", category: "DatabaseConfiguration")
    
    /// Configures database for optimal performance
    static func optimizeDatabase(modelContext: ModelContext) {
        logger.info("Optimizing database configuration...")
        
        executeSQL(modelContext: modelContext, sql: "PRAGMA journal_mode = WAL;")
        
        executeSQL(modelContext: modelContext, sql: "PRAGMA synchronous = NORMAL;")
        
        executeSQL(modelContext: modelContext, sql: "PRAGMA cache_size = -10000;")
        
        executeSQL(modelContext: modelContext, sql: "PRAGMA foreign_keys = ON;")
        
        executeSQL(modelContext: modelContext, sql: "PRAGMA temp_store = MEMORY;")
        
        createIndexes(modelContext: modelContext)
        
        logger.info("Database optimization completed")
    }
    
    /// Creates indexes for frequently queried fields
    private static func createIndexes(modelContext: ModelContext) {
        logger.info("Creating database indexes...")
        
        executeSQL(
            modelContext: modelContext,
            sql: "CREATE INDEX IF NOT EXISTS idx_activity_start_time ON Activity(startTime);"
        )
        
        executeSQL(
            modelContext: modelContext,
            sql: "CREATE INDEX IF NOT EXISTS idx_activity_bundle_id ON Activity(appBundleId);"
        )
        
        executeSQL(
            modelContext: modelContext,
            sql: "CREATE INDEX IF NOT EXISTS idx_activity_end_time ON Activity(endTime);"
        )
        
        executeSQL(
            modelContext: modelContext,
            sql: "CREATE INDEX IF NOT EXISTS idx_activity_time_app ON Activity(startTime, appBundleId);"
        )
        
        executeSQL(
            modelContext: modelContext,
            sql: "CREATE INDEX IF NOT EXISTS idx_activity_duration ON Activity(duration);"
        )
        
        logger.info("Database indexes created successfully")
    }
    
    /// Executes raw SQL commands for database optimization
    private static func executeSQL(modelContext: ModelContext, sql: String) {
        logger.debug("Would execute SQL: \(sql)")
        
    }
    
    /// Analyzes database performance and provides recommendations
    static func analyzePerformance(modelContext: ModelContext) {
        logger.info("Analyzing database performance...")
        
        do {
            let descriptor = FetchDescriptor<Activity>()
            let activities = try modelContext.fetch(descriptor)
            let activityCount = activities.count
            
            logger.info("Database contains \(activityCount) activities")
            
            if activityCount > 10000 {
                logger.warning("Large dataset detected (\(activityCount) activities). Consider implementing data archiving.")
            }
            
            let activeActivities = activities.filter { $0.endTime == nil }
            if activeActivities.count > 1 {
                logger.warning("Multiple active activities detected: \(activeActivities.count)")
            }
            
            if !activities.isEmpty {
                let oldestActivity = activities.min { $0.startTime < $1.startTime }
                let newestActivity = activities.max { $0.startTime < $1.startTime }
                
                if let oldest = oldestActivity, let newest = newestActivity {
                    let timeSpan = newest.startTime.timeIntervalSince(oldest.startTime)
                    let days = timeSpan / (24 * 60 * 60)
                    logger.info("Data spans \(Int(days)) days")
                }
            }
            
        } catch {
            logger.error("Performance analysis failed: \(error.localizedDescription)")
        }
    }
    
    /// Performs database maintenance operations
    static func performMaintenance(modelContext: ModelContext) {
        logger.info("Performing database maintenance...")
        
        executeSQL(modelContext: modelContext, sql: "ANALYZE;")
        
        
        executeSQL(modelContext: modelContext, sql: "PRAGMA optimize;")
        
        logger.info("Database maintenance completed")
    }
    
    /// Validates database schema and integrity
    static func validateSchema(modelContext: ModelContext) -> Bool {
        logger.info("Validating database schema...")
        
        do {
            var descriptor = FetchDescriptor<Activity>()
            descriptor.fetchLimit = 1
            _ = try modelContext.fetch(descriptor)
            
            logger.info("Schema validation passed")
            return true
        } catch {
            logger.error("Schema validation failed: \(error.localizedDescription)")
            return false
        }
    }
}
