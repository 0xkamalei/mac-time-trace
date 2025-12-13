import AppKit
import Foundation
import SwiftData
import SwiftUI
import os

@MainActor
class ProjectManager: ObservableObject {
    static let shared = ProjectManager()
    
    // We keep modelContext access for CRUD operations
    private var modelContext: ModelContext?
    
    private init() {}
    
    func setModelContext(_ modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Core CRUD Operations
    
    /// Creates a new project
    func createProject(name: String, color: Color, parentID: String? = nil) async throws -> Project {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ProjectError.invalidName("Name cannot be empty")
        }
        
        // Basic duplicate check could be added here if needed, 
        // but for "reducing complexity" we might rely on UI validation or allow duplicates (users can rename).
        // Let's keep it simple.
        
        let project = Project(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            color: color,
            parentID: parentID,
            sortOrder: 0 // Logic to put at end?
        )
        
        if let modelContext = modelContext {
            // Calculate sort order if needed
            // For MVP simplicity: fetch siblings and add 1
            let descriptor = FetchDescriptor<Project>(predicate: #Predicate { $0.parentID == parentID })
            let siblings = try? modelContext.fetch(descriptor)
            project.sortOrder = (siblings?.count ?? 0)
            
            modelContext.insert(project)
            try modelContext.save()
        }
        
        return project
    }
    
    /// Updates an existing project
    func updateProject(_ project: Project, name: String? = nil, color: Color? = nil, parentID: String? = nil) async throws {
        if let name = name {
            project.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let color = color {
            project.color = color
        }
        
        // Handle hierarchy move
        if let parentID = parentID, parentID != project.parentID {
            // validation: prevent circular reference
            if parentID == project.id { throw ProjectError.circularReference }
            // deeper validation requires querying ancestry logic which we removed from Manager.
            // For now, assume UI prevents obvious self-parenting.
            project.parentID = parentID.isEmpty ? nil : parentID
        } else if parentID == "" {
             // Moved to root
             project.parentID = nil
        }
        
        try modelContext?.save()
    }
    
    /// Deletes a project
    func deleteProject(_ project: Project) async throws {
        // Cascade delete logic or reassign
        // For simplicity: delete project. 
        // If we want to support children strategy, we need to query children.
        
        guard let modelContext = modelContext else { return }
        
        // Fetch children to handle
        let projectID = project.id
        let childrenDescriptor = FetchDescriptor<Project>(predicate: #Predicate { $0.parentID == projectID })
        if let children = try? modelContext.fetch(childrenDescriptor) {
            // Default strategy: Move children to project's parent (lift up)
            for child in children {
                child.parentID = project.parentID
            }
        }
        
        modelContext.delete(project)
        try modelContext.save()
        
        NotificationCenter.default.post(
             name: .projectWasDeleted,
             object: nil,
             userInfo: ["projectId": project.id]
         )
    }
    
    // MARK: - Reordering
    
    func reorderProject(_ project: Project, to newIndex: Int, in parentID: String?) async throws {
         project.sortOrder = newIndex
         if let context = modelContext {
             try context.save()
         }
    }
    
    // Simple helper to fetch all (for legacy reasons if needed)
    func getAllProjects() async throws -> [Project] {
        guard let modelContext = modelContext else { return [] }
        let descriptor = FetchDescriptor<Project>(sortBy: [SortDescriptor(\.sortOrder)])
        return try modelContext.fetch(descriptor)
    }
    
    // Legacy helper
    func getRootProjects() async throws -> [Project] {
        guard let modelContext = modelContext else { return [] }
        let descriptor = FetchDescriptor<Project>(predicate: #Predicate { $0.parentID == nil }, sortBy: [SortDescriptor(\.sortOrder)])
        return try modelContext.fetch(descriptor)
    }
    
    func moveProject(_ project: Project, to parent: Project?) async throws {
        project.parentID = parent?.id
        if let context = modelContext {
            try context.save()
        }
    }
    
    // Helper to get children
    func getChildren(of parentID: String) async throws -> [Project] {
        guard let modelContext = modelContext else { return [] }
        let descriptor = FetchDescriptor<Project>(predicate: #Predicate { $0.parentID == parentID }, sortBy: [SortDescriptor(\.sortOrder)])
        return try modelContext.fetch(descriptor)
    }

    /// Fetches a project by ID synchronously using the current model context
    func getProject(by id: String) -> Project? {
        guard let modelContext = modelContext else { return nil }
        let descriptor = FetchDescriptor<Project>(predicate: #Predicate { $0.id == id })
        return try? modelContext.fetch(descriptor).first
    }

    func findProject(by id: String) -> Project? {
        getProject(by: id)
    }

    func buildProjectTree() -> [Project] {
        // Temporary fix for views expecting this method.
        // In a real app avoiding caching, views should build tree or use hierarchical fetch.
        // For now, return empty or try to fetch all (but this is async usually).
        // Since we need to return synchronously, we can try fetching all.
        guard let modelContext = modelContext else { return [] }
        let descriptor = FetchDescriptor<Project>(sortBy: [SortDescriptor(\.sortOrder)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}

extension Notification.Name {
    static let projectWasDeleted = Notification.Name("projectWasDeleted")
}


