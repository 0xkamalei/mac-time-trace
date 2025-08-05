//
//  time_vscodeApp.swift
//  time-vscode
//
//  Created by seven on 2025/7/1.
//

import SwiftUI
import SwiftData
import OSLog

@main
struct time_vscodeApp: App {
    private static let logger = Logger(subsystem: "com.time.vscode", category: "App")
    
    var sharedModelContainer: ModelContainer = {
        // Define schema with all models
        let schema = Schema([
            Item.self,
            Activity.self,
        ])
        
        // Configure ModelConfiguration for optimal SQLite performance
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .automatic,
            cloudKitDatabase: .none // Keep data local for privacy
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Get main context for initialization
            let context = container.mainContext
            
            // Perform migration if needed
            SchemaMigration.performMigrationIfNeeded(modelContext: context)
            
            // Optimize database configuration
            DatabaseConfiguration.optimizeDatabase(modelContext: context)
            
            // Validate schema integrity
            if !DatabaseConfiguration.validateSchema(modelContext: context) {
                logger.error("Schema validation failed during initialization")
            }
            
            logger.info("ModelContainer initialized successfully")
            return container
        } catch {
            logger.error("Could not create ModelContainer: \(error.localizedDescription)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup("") {
            ContentView()
                .environmentObject(appState)
        }
        .modelContainer(sharedModelContainer)
    }
}
