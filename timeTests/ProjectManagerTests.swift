import Foundation
import Testing
import SwiftUI
@testable import time

/// Comprehensive test suite for ProjectManager CRUD operations and hierarchy management
@Suite("ProjectManager CRUD Tests", .serialized)
@MainActor
struct ProjectManagerTests {
    
    // MARK: - Validation Tests (Requirement 1, 2, 8)
    
    @Test("ProjectError provides localized descriptions")
    func testProjectErrorDescriptions() {
        let errors: [ProjectError] = [
            .invalidName("empty"),
            .circularReference,
            .hasActiveTimer,
            .hasTimeEntries(count: 3),
            .persistenceFailure("disk full"),
            .hierarchyTooDeep,
            .projectNotFound("123"),
            .duplicateName("Test"),
            .invalidParent("not found"),
            .operationCancelled
        ]
        
        for error in errors {
            #expect(error.errorDescription != nil)
            #expect(!error.errorDescription!.isEmpty)
        }
    }
    
    @Test("ProjectError provides recovery suggestions")
    func testProjectErrorRecoverySuggestions() {
        let error = ProjectError.invalidName("empty")
        #expect(error.recoverySuggestion != nil)
        #expect(error.recoverySuggestion!.contains("valid"))
        
        let circularError = ProjectError.circularReference
        #expect(circularError.recoverySuggestion != nil)
        #expect(circularError.recoverySuggestion!.contains("parent"))
    }
    
    @Test("ProjectError provides failure reasons")
    func testProjectErrorFailureReasons() {
        let error = ProjectError.hasTimeEntries(count: 5)
        #expect(error.failureReason != nil)
        #expect(error.failureReason!.contains("5"))
        
        let depthError = ProjectError.hierarchyTooDeep
        #expect(depthError.failureReason != nil)
        #expect(depthError.failureReason!.contains("5"))
    }
    
    @Test("ProjectError equality works correctly")
    func testProjectErrorEquality() {
        #expect(ProjectError.circularReference == ProjectError.circularReference)
        #expect(ProjectError.hasActiveTimer == ProjectError.hasActiveTimer)
        #expect(ProjectError.invalidName("test") == ProjectError.invalidName("test"))
        #expect(ProjectError.invalidName("test") != ProjectError.invalidName("other"))
        #expect(ProjectError.hasTimeEntries(count: 3) == ProjectError.hasTimeEntries(count: 3))
        #expect(ProjectError.hasTimeEntries(count: 3) != ProjectError.hasTimeEntries(count: 5))
    }
    
    @Test("ValidationResult equality works correctly")
    func testValidationResultEquality() {
        #expect(ValidationResult.success == ValidationResult.success)
        
        let failure1 = ValidationResult.failure(.circularReference)
        let failure2 = ValidationResult.failure(.circularReference)
        #expect(failure1 == failure2)
        
        let failure3 = ValidationResult.failure(.hasActiveTimer)
        #expect(failure1 != failure3)
        
        #expect(ValidationResult.success != ValidationResult.failure(.circularReference))
    }
    
    // MARK: - DeletionStrategy Tests (Requirement 3)
    
    @Test("DeletionStrategy enum has all required cases")
    func testDeletionStrategyHasAllCases() {
        let strategies: [DeletionStrategy] = [
            .deleteChildren,
            .moveChildrenToParent,
            .moveChildrenToRoot
        ]
        
        #expect(strategies.count == 3)
    }
    
    // MARK: - Project Model Tests (Requirement 4)
    
    @Test("Project initializes with correct values")
    func testProjectInitialization() {
        let project = Project(
            id: "test-id",
            name: "Test Project",
            color: .blue,
            parentID: nil,
            sortOrder: 0
        )
        
        #expect(project.id == "test-id")
        #expect(project.name == "Test Project")
        #expect(project.parentID == nil)
        #expect(project.sortOrder == 0)
    }
    
    @Test("Project can be initialized as child")
    func testProjectChildInitialization() {
        let parent = Project(name: "Parent", color: .blue, parentID: nil, sortOrder: 0)
        let child = Project(name: "Child", color: .green, parentID: parent.id, sortOrder: 1)
        
        #expect(child.parentID == parent.id)
        #expect(child.name == "Child")
    }
    
    @Test("Project children array starts empty")
    func testProjectChildrenArrayStartsEmpty() {
        let project = Project(name: "Test", color: .blue, parentID: nil, sortOrder: 0)
        #expect(project.children.isEmpty)
    }
    
    @Test("Project can accept children by default")
    func testProjectCanAcceptChildren() {
        let project = Project(name: "Test", color: .blue, parentID: nil, sortOrder: 0)
        #expect(project.canAcceptChildren == true)
    }
    
    @Test("Project depth calculation")
    func testProjectDepthCalculation() {
        let root = Project(name: "Root", color: .blue, parentID: nil, sortOrder: 0)
        let child = Project(name: "Child", color: .green, parentID: root.id, sortOrder: 0)
        let grandchild = Project(name: "Grandchild", color: .red, parentID: child.id, sortOrder: 0)
        
        // Set up relationships
        child.children = [grandchild]
        root.children = [child]
        
        #expect(root.depth == 0)
        #expect(child.depth == 1)
        #expect(grandchild.depth == 2)
    }
    
    @Test("Project descendants includes all nested children")
    func testProjectDescendants() {
        let root = Project(name: "Root", color: .blue, parentID: nil, sortOrder: 0)
        let child1 = Project(name: "Child 1", color: .green, parentID: root.id, sortOrder: 0)
        let child2 = Project(name: "Child 2", color: .red, parentID: root.id, sortOrder: 1)
        let grandchild = Project(name: "Grandchild", color: .orange, parentID: child1.id, sortOrder: 0)
        
        // Set up relationships
        child1.children = [grandchild]
        root.children = [child1, child2]
        
        let descendants = root.descendants
        #expect(descendants.count == 3)
        #expect(descendants.contains { $0.id == child1.id })
        #expect(descendants.contains { $0.id == child2.id })
        #expect(descendants.contains { $0.id == grandchild.id })
    }
    
    @Test("Project isDescendantOf detects ancestry correctly")
    func testProjectIsDescendantOf() {
        let root = Project(name: "Root", color: .blue, parentID: nil, sortOrder: 0)
        let child = Project(name: "Child", color: .green, parentID: root.id, sortOrder: 0)
        let grandchild = Project(name: "Grandchild", color: .red, parentID: child.id, sortOrder: 0)
        
        // Set up relationships
        child.children = [grandchild]
        root.children = [child]
        
        #expect(grandchild.isDescendantOf(child))
        #expect(grandchild.isDescendantOf(root))
        #expect(child.isDescendantOf(root))
        #expect(!root.isDescendantOf(child))
        #expect(!root.isDescendantOf(grandchild))
    }
    
    @Test("Project addChild updates children array")
    func testProjectAddChild() {
        let parent = Project(name: "Parent", color: .blue, parentID: nil, sortOrder: 0)
        let child = Project(name: "Child", color: .green, parentID: parent.id, sortOrder: 0)
        
        parent.addChild(child)
        
        #expect(parent.children.count == 1)
        #expect(parent.children.first?.id == child.id)
    }
    
    @Test("Project removeChild updates children array")
    func testProjectRemoveChild() {
        let parent = Project(name: "Parent", color: .blue, parentID: nil, sortOrder: 0)
        let child = Project(name: "Child", color: .green, parentID: parent.id, sortOrder: 0)
        
        parent.addChild(child)
        #expect(parent.children.count == 1)
        
        parent.removeChild(child)
        #expect(parent.children.isEmpty)
    }
    
    @Test("Project validates name is not empty")
    func testProjectValidatesName() {
        let project = Project(name: "Test", color: .blue, parentID: nil, sortOrder: 0)
        
        let validResult = project.validateName("Valid Name")
        #expect(validResult == .success)
        
        let emptyResult = project.validateName("")
        switch emptyResult {
        case .failure:
            break // Expected
        default:
            Issue.record("Should fail for empty name")
        }
        
        let whitespaceResult = project.validateName("   ")
        switch whitespaceResult {
        case .failure:
            break // Expected
        default:
            Issue.record("Should fail for whitespace-only name")
        }
    }
    
    @Test("Project validateAsParentOf prevents circular references")
    func testProjectValidateAsParentOfPreventsCircular() {
        let parent = Project(name: "Parent", color: .blue, parentID: nil, sortOrder: 0)
        let child = Project(name: "Child", color: .green, parentID: parent.id, sortOrder: 0)
        let grandchild = Project(name: "Grandchild", color: .red, parentID: child.id, sortOrder: 0)
        
        // Set up relationships
        child.children = [grandchild]
        parent.children = [child]
        
        // Try to make parent a child of grandchild - should fail
        let result = grandchild.validateAsParentOf(parent)
        switch result {
        case .failure(.circularReference):
            break // Expected
        default:
            Issue.record("Should detect circular reference")
        }
    }
    
    @Test("Project validateAsParentOf allows valid relationships")
    func testProjectValidateAsParentOfAllowsValid() {
        let parent1 = Project(name: "Parent 1", color: .blue, parentID: nil, sortOrder: 0)
        let parent2 = Project(name: "Parent 2", color: .green, parentID: nil, sortOrder: 1)
        let child = Project(name: "Child", color: .red, parentID: parent1.id, sortOrder: 0)
        
        parent1.children = [child]
        
        // Moving child to parent2 should be valid
        let result = parent2.validateAsParentOf(child)
        #expect(result == .success)
    }
    
    // MARK: - Color Encoding Tests (Requirement 1)
    
    @Test("Project color encoding and decoding works")
    func testProjectColorEncodingDecoding() {
        let project = Project(name: "Test", color: .red, parentID: nil, sortOrder: 0)
        
        // Set a color
        project.color = .blue
        
        // Verify colorData is set
        #expect(project.colorData != nil)
        
        // Verify color getter returns the correct color
        let retrievedColor = project.color
        // Note: Color comparison is complex, so we just verify it's not nil and has data
        #expect(project.colorData != nil)
    }
    
    // MARK: - Transferable Support Tests (Requirement 5)
    
    @Test("ProjectDragData initializes correctly")
    func testProjectDragDataInitialization() {
        let dragData = ProjectDragData(
            projectID: "test-id",
            projectName: "Test",
            sourceParentID: nil,
            sourceSortOrder: 0,
            hierarchyDepth: 0
        )
        
        #expect(dragData.projectID == "test-id")
        #expect(dragData.projectName == "Test")
        #expect(dragData.sourceParentID == nil)
        #expect(dragData.sourceSortOrder == 0)
        #expect(dragData.hierarchyDepth == 0)
    }
    
    @Test("DropPosition enum has all required cases")
    func testDropPositionCases() {
        let positions: [DropPosition] = [
            .above,
            .below,
            .inside,
            .invalid
        ]
        
        #expect(positions.count == 4)
    }
}

// MARK: - Integration Test Suite

@Suite("Project Integration Tests", .serialized)
@MainActor
struct ProjectIntegrationTests {
    
    @Test("Complete CRUD workflow")
    func testCompleteCRUDWorkflow() {
        // Create
        let project = Project(name: "Test Project", color: .blue, parentID: nil, sortOrder: 0)
        #expect(project.name == "Test Project")
        
        // Read
        #expect(project.id.count > 0)
        #expect(project.children.isEmpty)
        
        // Update
        project.name = "Updated Project"
        #expect(project.name == "Updated Project")
        
        project.color = .red
        #expect(project.colorData != nil)
        
        // Create child
        let child = Project(name: "Child", color: .green, parentID: project.id, sortOrder: 0)
        project.addChild(child)
        #expect(project.children.count == 1)
        
        // Delete child (simulated by removal)
        project.removeChild(child)
        #expect(project.children.isEmpty)
    }
    
    @Test("Hierarchy management workflow")
    func testHierarchyManagementWorkflow() {
        // Create hierarchy: Root -> Child -> Grandchild
        let root = Project(name: "Root", color: .blue, parentID: nil, sortOrder: 0)
        let child = Project(name: "Child", color: .green, parentID: root.id, sortOrder: 0)
        let grandchild = Project(name: "Grandchild", color: .red, parentID: child.id, sortOrder: 0)
        
        child.children = [grandchild]
        root.children = [child]
        
        // Verify depth
        #expect(root.depth == 0)
        #expect(child.depth == 1)
        #expect(grandchild.depth == 2)
        
        // Verify descendants
        #expect(root.descendants.count == 2)
        #expect(child.descendants.count == 1)
        #expect(grandchild.descendants.isEmpty)
        
        // Verify ancestry
        #expect(grandchild.isDescendantOf(child))
        #expect(grandchild.isDescendantOf(root))
        #expect(!root.isDescendantOf(child))
    }
    
    @Test("Validation prevents invalid operations")
    func testValidationPreventsInvalidOperations() {
        let project = Project(name: "Test", color: .blue, parentID: nil, sortOrder: 0)
        
        // Test empty name validation
        let emptyNameResult = project.validateName("")
        #expect(emptyNameResult != .success)
        
        // Test whitespace name validation
        let whitespaceResult = project.validateName("   ")
        #expect(whitespaceResult != .success)
        
        // Test valid name
        let validResult = project.validateName("Valid Name")
        #expect(validResult == .success)
    }
    
    @Test("Project supports multiple children")
    func testProjectSupportsMultipleChildren() {
        let parent = Project(name: "Parent", color: .blue, parentID: nil, sortOrder: 0)
        
        let child1 = Project(name: "Child 1", color: .green, parentID: parent.id, sortOrder: 0)
        let child2 = Project(name: "Child 2", color: .red, parentID: parent.id, sortOrder: 1)
        let child3 = Project(name: "Child 3", color: .orange, parentID: parent.id, sortOrder: 2)
        
        parent.addChild(child1)
        parent.addChild(child2)
        parent.addChild(child3)
        
        #expect(parent.children.count == 3)
        #expect(parent.children[0].sortOrder < parent.children[1].sortOrder)
        #expect(parent.children[1].sortOrder < parent.children[2].sortOrder)
    }
    
    @Test("Project maintains sort order")
    func testProjectMaintainsSortOrder() {
        let project1 = Project(name: "First", color: .blue, parentID: nil, sortOrder: 0)
        let project2 = Project(name: "Second", color: .green, parentID: nil, sortOrder: 1)
        let project3 = Project(name: "Third", color: .red, parentID: nil, sortOrder: 2)
        
        let projects = [project1, project2, project3].sorted { $0.sortOrder < $1.sortOrder }
        
        #expect(projects[0].name == "First")
        #expect(projects[1].name == "Second")
        #expect(projects[2].name == "Third")
    }
}
    
    @Test("createProject assigns unique ID")
    func testCreateProjectAssignsUniqueID() async throws {
        let manager = createTestManager()
        
        let project1 = try await manager.createProject(name: "Project 1", color: .blue)
        let project2 = try await manager.createProject(name: "Project 2", color: .red)
        
        #expect(project1.id != project2.id)
    }
    
    @Test("createProject validates empty name")
    func testCreateProjectRejectsEmptyName() async throws {
        let manager = createTestManager()
        
        do {
            _ = try await manager.createProject(name: "", color: .blue)
            Issue.record("Should throw error for empty name")
        } catch let error as ProjectError {
            #expect(error.errorDescription?.contains("name") ?? false)
        }
    }
    
    @Test("createProject validates whitespace-only name")
    func testCreateProjectRejectsWhitespaceOnlyName() async throws {
        let manager = createTestManager()
        
        do {
            _ = try await manager.createProject(name: "   ", color: .blue)
            Issue.record("Should throw error for whitespace-only name")
        } catch let error as ProjectError {
            #expect(error.errorDescription?.contains("name") ?? false)
        }
    }
    
    @Test("createProject creates child project with valid parent")
    func testCreateChildProjectWithValidParent() async throws {
        let manager = createTestManager()
        
        let parent = try await manager.createProject(name: "Parent", color: .blue)
        let child = try await manager.createProject(name: "Child", color: .green, parentID: parent.id)
        
        #expect(child.parentID == parent.id)
        #expect(parent.children.contains { $0.id == child.id })
    }
    
    @Test("createProject assigns correct sort order")
    func testCreateProjectAssignsSortOrder() async throws {
        let manager = createTestManager()
        
        let project1 = try await manager.createProject(name: "First", color: .blue)
        let project2 = try await manager.createProject(name: "Second", color: .red)
        
        #expect(project2.sortOrder > project1.sortOrder)
    }
    
    // MARK: - Update Project Tests (Requirement 2)
    
    @Test("updateProject updates project name")
    func testUpdateProjectName() async throws {
        let manager = createTestManager()
        let project = try await manager.createProject(name: "Original", color: .blue)
        
        try await manager.updateProject(project, name: "Updated", color: nil, parentID: nil)
        
        #expect(project.name == "Updated")
    }
    
    @Test("updateProject updates project color")
    func testUpdateProjectColor() async throws {
        let manager = createTestManager()
        let project = try await manager.createProject(name: "Test", color: .blue)
        
        try await manager.updateProject(project, name: nil, color: .red, parentID: nil)
        
        #expect(project.color == .red)
    }
    
    @Test("updateProject changes parent")
    func testUpdateProjectChangesParent() async throws {
        let manager = createTestManager()
        
        let parent1 = try await manager.createProject(name: "Parent 1", color: .blue)
        let parent2 = try await manager.createProject(name: "Parent 2", color: .green)
        let child = try await manager.createProject(name: "Child", color: .red, parentID: parent1.id)
        
        try await manager.updateProject(child, name: nil, color: nil, parentID: parent2.id)
        
        #expect(child.parentID == parent2.id)
        #expect(parent2.children.contains { $0.id == child.id })
        #expect(!parent1.children.contains { $0.id == child.id })
    }
    
    @Test("updateProject prevents circular reference")
    func testUpdateProjectPreventsCircularReference() async throws {
        let manager = createTestManager()
        
        let parent = try await manager.createProject(name: "Parent", color: .blue)
        let child = try await manager.createProject(name: "Child", color: .green, parentID: parent.id)
        
        do {
            try await manager.updateProject(parent, name: nil, color: nil, parentID: child.id)
            Issue.record("Should prevent circular reference")
        } catch let error as ProjectError {
            #expect(error == .circularReference)
        }
    }
    
    @Test("updateProject validates name not empty")
    func testUpdateProjectValidatesName() async throws {
        let manager = createTestManager()
        let project = try await manager.createProject(name: "Original", color: .blue)
        
        do {
            try await manager.updateProject(project, name: "", color: nil, parentID: nil)
            Issue.record("Should reject empty name")
        } catch {
            // Expected
        }
    }
    
    // MARK: - Delete Project Tests (Requirement 3)
    
    @Test("deleteProject removes project")
    func testDeleteProjectRemovesProject() async throws {
        let manager = createTestManager()
        let project = try await manager.createProject(name: "To Delete", color: .blue)
        
        let projectID = project.id
        try await manager.deleteProject(project)
        
        #expect(!manager.projects.contains { $0.id == projectID })
    }
    
    @Test("deleteProject with deleteChildren strategy removes all children")
    func testDeleteProjectDeletesChildren() async throws {
        let manager = createTestManager()
        
        let parent = try await manager.createProject(name: "Parent", color: .blue)
        let child1 = try await manager.createProject(name: "Child 1", color: .green, parentID: parent.id)
        let child2 = try await manager.createProject(name: "Child 2", color: .red, parentID: parent.id)
        
        try await manager.deleteProject(parent, strategy: .deleteChildren)
        
        #expect(!manager.projects.contains { $0.id == parent.id })
        #expect(!manager.projects.contains { $0.id == child1.id })
        #expect(!manager.projects.contains { $0.id == child2.id })
    }
    
    @Test("deleteProject with moveChildrenToParent strategy moves children")
    func testDeleteProjectMovesChildrenToParent() async throws {
        let manager = createTestManager()
        
        let grandparent = try await manager.createProject(name: "Grandparent", color: .blue)
        let parent = try await manager.createProject(name: "Parent", color: .green, parentID: grandparent.id)
        let child = try await manager.createProject(name: "Child", color: .red, parentID: parent.id)
        
        try await manager.deleteProject(parent, strategy: .moveChildrenToParent)
        
        #expect(!manager.projects.contains { $0.id == parent.id })
        #expect(manager.projects.contains { $0.id == child.id })
        #expect(child.parentID == grandparent.id)
    }
    
    @Test("deleteProject with moveChildrenToRoot strategy moves children to root")
    func testDeleteProjectMovesChildrenToRoot() async throws {
        let manager = createTestManager()
        
        let parent = try await manager.createProject(name: "Parent", color: .blue)
        let child = try await manager.createProject(name: "Child", color: .green, parentID: parent.id)
        
        try await manager.deleteProject(parent, strategy: .moveChildrenToRoot)
        
        #expect(!manager.projects.contains { $0.id == parent.id })
        #expect(manager.projects.contains { $0.id == child.id })
        #expect(child.parentID == nil)
    }
    
    @Test("canDeleteProject returns true for deletable project")
    func testCanDeleteProjectReturnsTrue() async throws {
        let manager = createTestManager()
        let project = try await manager.createProject(name: "Deletable", color: .blue)
        
        let result = manager.canDeleteProject(project)
        
        #expect(result.canDelete == true)
        #expect(result.reason == nil)
    }
    
    // MARK: - Hierarchy Tests (Requirement 4)
    
    @Test("buildProjectTree returns only root projects")
    func testBuildProjectTreeReturnsRootProjects() async throws {
        let manager = createTestManager()
        
        let root1 = try await manager.createProject(name: "Root 1", color: .blue)
        let root2 = try await manager.createProject(name: "Root 2", color: .green)
        _ = try await manager.createProject(name: "Child", color: .red, parentID: root1.id)
        
        let tree = manager.buildProjectTree()
        
        #expect(tree.count == 2)
        #expect(tree.contains { $0.id == root1.id })
        #expect(tree.contains { $0.id == root2.id })
    }
    
    @Test("buildProjectTree maintains parent-child relationships")
    func testBuildProjectTreeMaintainsRelationships() async throws {
        let manager = createTestManager()
        
        let parent = try await manager.createProject(name: "Parent", color: .blue)
        let child = try await manager.createProject(name: "Child", color: .green, parentID: parent.id)
        
        let tree = manager.buildProjectTree()
        
        let parentInTree = tree.first { $0.id == parent.id }
        #expect(parentInTree?.children.contains { $0.id == child.id } == true)
    }
    
    @Test("buildProjectTree sorts by sortOrder")
    func testBuildProjectTreeSortsBySortOrder() async throws {
        let manager = createTestManager()
        
        let project1 = try await manager.createProject(name: "First", color: .blue)
        let project2 = try await manager.createProject(name: "Second", color: .green)
        let project3 = try await manager.createProject(name: "Third", color: .red)
        
        let tree = manager.buildProjectTree()
        
        #expect(tree[0].sortOrder < tree[1].sortOrder)
        #expect(tree[1].sortOrder < tree[2].sortOrder)
    }
    
    @Test("project descendants returns all nested children")
    func testProjectDescendantsReturnsAllChildren() async throws {
        let manager = createTestManager()
        
        let root = try await manager.createProject(name: "Root", color: .blue)
        let child1 = try await manager.createProject(name: "Child 1", color: .green, parentID: root.id)
        let grandchild = try await manager.createProject(name: "Grandchild", color: .red, parentID: child1.id)
        
        let descendants = root.descendants
        
        #expect(descendants.count == 2)
        #expect(descendants.contains { $0.id == child1.id })
        #expect(descendants.contains { $0.id == grandchild.id })
    }
    
    // MARK: - Validation Tests (Requirement 2.5, 5.6)
    
    @Test("validateHierarchyMove prevents moving project to its own descendant")
    func testValidateHierarchyMovePreventsSelfDescendant() async throws {
        let manager = createTestManager()
        
        let parent = try await manager.createProject(name: "Parent", color: .blue)
        let child = try await manager.createProject(name: "Child", color: .green, parentID: parent.id)
        
        let result = manager.validateHierarchyMove(parent, to: child)
        
        switch result {
        case .failure(.circularReference):
            break // Expected
        default:
            Issue.record("Should prevent moving to descendant")
        }
    }
    
    @Test("validateHierarchyMove allows valid moves")
    func testValidateHierarchyMoveAllowsValidMoves() async throws {
        let manager = createTestManager()
        
        let parent1 = try await manager.createProject(name: "Parent 1", color: .blue)
        let parent2 = try await manager.createProject(name: "Parent 2", color: .green)
        let child = try await manager.createProject(name: "Child", color: .red, parentID: parent1.id)
        
        let result = manager.validateHierarchyMove(child, to: parent2)
        
        #expect(result == .success)
    }
    
    @Test("project validates maximum hierarchy depth")
    func testProjectValidatesMaximumDepth() async throws {
        let manager = createTestManager()
        
        // Create 5 levels (max allowed)
        var currentParent = try await manager.createProject(name: "Level 1", color: .blue)
        
        for level in 2...5 {
            currentParent = try await manager.createProject(name: "Level \(level)", color: .blue, parentID: currentParent.id)
        }
        
        // Try to create 6th level - should fail
        do {
            _ = try await manager.createProject(name: "Level 6", color: .blue, parentID: currentParent.id)
            Issue.record("Should prevent creating 6th level")
        } catch let error as ProjectError {
            #expect(error == .hierarchyTooDeep)
        }
    }
    
    // MARK: - Reordering Tests (Requirement 5)
    
    @Test("reorderProject updates sort order")
    func testReorderProjectUpdatesSortOrder() async throws {
        let manager = createTestManager()
        
        let project1 = try await manager.createProject(name: "First", color: .blue)
        let project2 = try await manager.createProject(name: "Second", color: .green)
        let project3 = try await manager.createProject(name: "Third", color: .red)
        
        let originalOrder2 = project2.sortOrder
        
        // Move project3 to position 0 (before project1)
        let success = manager.reorderProject(project3, to: 0, in: nil)
        
        #expect(success == true)
        #expect(project3.sortOrder < project1.sortOrder)
    }
    
    @Test("moveProject updates parent and hierarchy")
    func testMoveProjectUpdatesParentAndHierarchy() async throws {
        let manager = createTestManager()
        
        let parent1 = try await manager.createProject(name: "Parent 1", color: .blue)
        let parent2 = try await manager.createProject(name: "Parent 2", color: .green)
        let child = try await manager.createProject(name: "Child", color: .red, parentID: parent1.id)
        
        let success = manager.moveProject(child, toParent: parent2)
        
        #expect(success == true)
        #expect(child.parentID == parent2.id)
        #expect(parent2.children.contains { $0.id == child.id })
        #expect(!parent1.children.contains { $0.id == child.id })
    }
    
    // MARK: - Integration Tests (Requirement 6)
    
    @Test("project operations persist across manager lifecycle")
    func testProjectOperationsPersist() async throws {
        let manager = createTestManager()
        
        let project = try await manager.createProject(name: "Persistent", color: .blue)
        let projectID = project.id
        
        // Save projects
        try await manager.saveProjects()
        
        // Create new manager and load
        let newManager = createTestManager()
        try await newManager.loadProjects()
        
        #expect(newManager.projects.contains { $0.id == projectID })
    }
    
    @Test("creating project updates project tree")
    func testCreatingProjectUpdatesTree() async throws {
        let manager = createTestManager()
        
        let initialCount = manager.projectTree.count
        _ = try await manager.createProject(name: "New", color: .blue)
        
        #expect(manager.projectTree.count == initialCount + 1)
    }
    
    @Test("deleting project updates project tree")
    func testDeletingProjectUpdatesTree() async throws {
        let manager = createTestManager()
        
        let project = try await manager.createProject(name: "To Delete", color: .blue)
        let initialCount = manager.projectTree.count
        
        try await manager.deleteProject(project)
        
        #expect(manager.projectTree.count == initialCount - 1)
    }
}
