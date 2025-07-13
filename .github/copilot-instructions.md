# GitHub Copilot Instructions

## Project Overview
This is a native macOS time tracking application built with SwiftUI and SwiftData, similar to the Timing app. Focus on clean, maintainable code that follows Apple's design patterns.

## Architecture Guidelines

### SwiftUI Patterns
- Use `@StateObject` for view models and `@ObservableObject` for shared state
- Prefer `@Published` properties for reactive UI updates
- Use `@Environment` for dependency injection
- Implement SwiftUI previews for all views with `#Preview`

### State Management
- Centralize app state in `AppState` class using `ObservableObject`
- Use SwiftData for data persistence with proper model relationships
- Implement hierarchical project structure with parent/child relationships
- Use index-based ordering for project hierarchy

### Code Style
- Follow Swift naming conventions (camelCase for variables, PascalCase for types)
- Use meaningful variable and function names
- Prefer guard statements for early returns
- Use extensions to organize code by functionality

### Data Models
- Use SwiftData's `@Model` macro for persistent data
- Implement proper Codable conformance for Color and other custom types
- Design models with clear relationships (parent/child for projects)
- Include computed properties for derived data

### UI Components
- Use SF Symbols for consistent iconography
- Implement color-coded projects for visual organization
- Use NavigationSplitView for macOS sidebar layouts
- Prefer sheet presentations for modal dialogs

### File Organization
- Group related files using Xcode groups (not folders)
- Separate Views, Models, and ViewModels into logical groups
- Keep utility functions in dedicated Extensions group
- Place mock data in separate files for testing

## Specific Patterns

### Project Hierarchy
```swift
// Prefer this pattern for project ordering
func moveProject(_ project: Project, to newIndex: Int) {
    // Update indices to maintain hierarchy
}
```

### Timer Management
```swift
// Use centralized timer state
@Published var isTimerRunning: Bool = false
@Published var activeProject: Project?
```

### Color Persistence
```swift
// Use custom encoding for SwiftUI Colors
extension Color: Codable {
    // Custom implementation for data persistence
}
```

## Build and Testing
- Build target: macOS 15.0+
- Use Xcode's built-in testing framework
- Implement unit tests for business logic
- Use SwiftUI previews for UI testing

## Performance Guidelines
- Use lazy loading for large project lists
- Implement efficient project tree computation
- Cache computed properties where appropriate
- Optimize SwiftData queries with proper predicates