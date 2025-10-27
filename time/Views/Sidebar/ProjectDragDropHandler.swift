import SwiftUI
import Foundation

/// A performance-optimized utility class that handles complex drag-and-drop logic for project hierarchies
class ProjectDragDropHandler: ObservableObject {
    
    // MARK: - Performance Optimization Cache
    
    /// Cache for expensive computations to avoid recalculation during drag operations
    private static var positionCache: [String: DropPosition] = [:]
    private static var validationCache: [String: DragValidationResult] = [:]
    private static var cacheInvalidationTimer: Timer?
    
    /// Clears performance caches periodically to prevent memory bloat
    private static func setupCacheInvalidation() {
        cacheInvalidationTimer?.invalidate()
        cacheInvalidationTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            positionCache.removeAll()
            validationCache.removeAll()
        }
    }
    
    // MARK: - Drop Position Detection
    
    /// Determines the precise drop position based on cursor location within a project row with caching
    /// - Parameters:
    ///   - location: The cursor location within the drop target
    ///   - targetProject: The project being dropped onto
    ///   - rowBounds: The bounds of the project row
    /// - Returns: The detected drop position
    static func getDropPosition(
        for location: CGPoint,
        targetProject: Project,
        rowBounds: CGRect
    ) -> DropPosition {
        let cacheKey = "\(targetProject.id)_\(Int(location.y))_\(Int(rowBounds.height))"
        
        if let cachedPosition = positionCache[cacheKey] {
            return cachedPosition
        }
        
        if cacheInvalidationTimer == nil {
            setupCacheInvalidation()
        }
        
        let rowHeight = rowBounds.height
        let topThreshold = rowHeight * 0.25
        let bottomThreshold = rowHeight * 0.75
        
        let position: DropPosition
        
        if location.y < topThreshold {
            position = .above
        } else if location.y > bottomThreshold {
            position = .below
        } else {
            position = targetProject.canAcceptChildren ? .inside : .below
        }
        
        positionCache[cacheKey] = position
        
        return position
    }
    
    /// Gets drop position with enhanced boundary detection
    /// - Parameters:
    ///   - location: The cursor location
    ///   - targetProject: The target project
    ///   - rowBounds: The row bounds
    ///   - draggedProject: The project being dragged
    /// - Returns: The validated drop position
    static func getValidatedDropPosition(
        for location: CGPoint,
        targetProject: Project,
        rowBounds: CGRect,
        draggedProject: Project
    ) -> DropPosition {
        let basePosition = getDropPosition(for: location, targetProject: targetProject, rowBounds: rowBounds)
        
        switch basePosition {
        case .inside:
            if !targetProject.canBeParentOf(draggedProject) {
                return .below // Fallback to below if can't be parent
            }
            return .inside
            
        case .above, .below:
            return basePosition
            
        case .invalid:
            return .invalid
        }
    }
    
    // MARK: - Visual Feedback
    
    /// Creates visual feedback configuration for different drop zones
    /// - Parameter position: The drop position
    /// - Returns: Visual feedback configuration
    static func getVisualFeedback(for position: DropPosition) -> DropVisualFeedback {
        switch position {
        case .above:
            return DropVisualFeedback(
                indicatorType: .line,
                position: .top,
                color: .accentColor,
                opacity: 0.8,
                thickness: 2
            )
            
        case .below:
            return DropVisualFeedback(
                indicatorType: .line,
                position: .bottom,
                color: .accentColor,
                opacity: 0.8,
                thickness: 2
            )
            
        case .inside:
            return DropVisualFeedback(
                indicatorType: .border,
                position: .overlay,
                color: .accentColor,
                opacity: 0.6,
                thickness: 2
            )
            
        case .invalid:
            return DropVisualFeedback(
                indicatorType: .border,
                position: .overlay,
                color: .red,
                opacity: 0.4,
                thickness: 1
            )
        }
    }
    
    // MARK: - Boundary Detection
    
    /// Validates if a drop area is within valid boundaries
    /// - Parameters:
    ///   - location: The drop location
    ///   - bounds: The container bounds
    ///   - margin: The margin for valid drop areas
    /// - Returns: True if within valid boundaries
    static func isWithinValidDropArea(
        location: CGPoint,
        bounds: CGRect,
        margin: CGFloat = 8
    ) -> Bool {
        let validArea = bounds.insetBy(dx: margin, dy: margin)
        return validArea.contains(location)
    }
    
    /// Detects if the cursor is near the edge of a container for auto-scroll
    /// - Parameters:
    ///   - location: The cursor location
    ///   - containerBounds: The container bounds
    ///   - scrollThreshold: The threshold distance from edge
    /// - Returns: Scroll direction if near edge, nil otherwise
    static func detectScrollZone(
        location: CGPoint,
        containerBounds: CGRect,
        scrollThreshold: CGFloat = 30
    ) -> ScrollDirection? {
        if location.y < scrollThreshold {
            return .up
        } else if location.y > containerBounds.height - scrollThreshold {
            return .down
        }
        return nil
    }
    
    // MARK: - Drop Position Preview
    
    /// Creates a preview indicator for the drop position
    /// - Parameters:
    ///   - position: The drop position
    ///   - targetProject: The target project
    /// - Returns: A view representing the drop preview
    @ViewBuilder
    static func createDropPreview(
        for position: DropPosition,
        targetProject: Project
    ) -> some View {
        let feedback = getVisualFeedback(for: position)
        
        switch feedback.indicatorType {
        case .line:
            Rectangle()
                .fill(feedback.color)
                .frame(height: feedback.thickness)
                .opacity(feedback.opacity)
                .animation(.easeInOut(duration: 0.2), value: position)
                
        case .border:
            RoundedRectangle(cornerRadius: 4)
                .stroke(feedback.color, lineWidth: feedback.thickness)
                .opacity(feedback.opacity)
                .animation(.easeInOut(duration: 0.2), value: position)
        }
    }
    
    // MARK: - Drag Validation
    
    /// Validates if a drag operation is allowed with performance caching
    /// - Parameters:
    ///   - draggedProject: The project being dragged
    ///   - targetProject: The target project
    ///   - position: The intended drop position
    /// - Returns: Validation result with error details if invalid
    static func validateDragOperation(
        draggedProject: Project,
        targetProject: Project,
        position: DropPosition
    ) -> DragValidationResult {
        
        let cacheKey = "\(draggedProject.id)_\(targetProject.id)_\(position)"
        
        if let cachedResult = validationCache[cacheKey] {
            return cachedResult
        }
        
        let result: DragValidationResult
        
        if draggedProject.id == targetProject.id {
            result = .invalid(.selfDrop)
        }
        else if isCircularReference(draggedProject: draggedProject, targetProject: targetProject) {
            result = .invalid(.circularReference)
        }
        else {
            result = validatePositionSpecificConstraints(
                draggedProject: draggedProject,
                targetProject: targetProject,
                position: position
            )
        }
        
        validationCache[cacheKey] = result
        
        return result
    }
    
    /// Optimized circular reference detection using breadth-first search
    private static func isCircularReference(draggedProject: Project, targetProject: Project) -> Bool {
        var queue: [Project] = [targetProject]
        var visited: Set<String> = []
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            
            if visited.contains(current.id) {
                continue
            }
            visited.insert(current.id)
            
            if current.id == draggedProject.id {
                return true
            }
            
            if let parentID = current.parentID {
                if parentID == draggedProject.id {
                    return true
                }
            }
        }
        
        return false
    }
    
    /// Validates position-specific constraints with optimized logic
    private static func validatePositionSpecificConstraints(
        draggedProject: Project,
        targetProject: Project,
        position: DropPosition
    ) -> DragValidationResult {
        
        switch position {
        case .inside:
            if targetProject.depth >= 4 { // Max 5 levels (0-4)
                return .invalid(.hierarchyTooDeep)
            }
            
            if !targetProject.canAcceptChildren {
                return .invalid(.cannotAcceptChildren)
            }
            
        case .above, .below:
            if let targetParentID = targetProject.parentID {
                if draggedProject.depth >= 5 { // Would exceed max depth
                    return .invalid(.hierarchyTooDeep)
                }
            }
            
        case .invalid:
            return .invalid(.invalidPosition)
        }
        
        return .valid
    }
}

// MARK: - Supporting Types

/// Visual feedback configuration for drop operations
struct DropVisualFeedback {
    enum IndicatorType {
        case line
        case border
    }
    
    enum Position {
        case top
        case bottom
        case overlay
    }
    
    let indicatorType: IndicatorType
    let position: Position
    let color: Color
    let opacity: Double
    let thickness: CGFloat
}

/// Scroll direction for auto-scroll during drag
enum ScrollDirection {
    case up
    case down
}

/// Result of drag validation
enum DragValidationResult {
    case valid
    case invalid(DragError)
}

/// Errors that can occur during drag operations
enum DragError {
    case selfDrop
    case circularReference
    case hierarchyTooDeep
    case cannotAcceptChildren
    case invalidPosition
    
    var localizedDescription: String {
        switch self {
        case .selfDrop:
            return "Cannot drop a project onto itself"
        case .circularReference:
            return "Cannot drop a project onto its descendant"
        case .hierarchyTooDeep:
            return "Project hierarchy would exceed maximum depth"
        case .cannotAcceptChildren:
            return "Target project cannot accept child projects"
        case .invalidPosition:
            return "Invalid drop position"
        }
    }
}
