# Implement "Assign to Project" in ActivitiesView

I will implement the "Assign to Project" functionality in the `ActivitiesView` as requested. This will allow users to right-click on any activity group (Project, App, or Context level) and assign all contained activities to a specific project.

## Proposed Changes

### 1. Modify `RecursiveActivityRow` in `ActivitiesView.swift`

I will update the `RecursiveActivityRow` struct to include the context menu logic.

-   **Add Environment & Query**:
    -   Inject `modelContext` to handle data updates.
    -   Query `allProjects` to populate the selection menu.
-   **Add Context Menu**:
    -   Add a `.contextMenu` modifier to the row.
    -   Include a "Assign to Project" menu item.
    -   List all available projects in a submenu.
    -   Add an "Unassigned" option to clear the project assignment.
-   **Implement Assignment Logic**:
    -   Create a helper function `assignToProject(_ project: Project?)`.
    -   This function will iterate through `group.activities` and update their `projectId`.
    -   It will then save the changes to `modelContext`.

### 2. Verification

-   The change will be applied directly to the view logic.
-   Since this is a UI behavior change, I will ensure the code compiles and follows the existing patterns (using `SwiftData` and `ActivityGroup` structure).

## File to be Edited

-   `time/Views/Activity/ActivitiesView.swift`

## User Experience

1.  User right-clicks on any row in the Hierarchical Activity View.
2.  A menu appears with "Assign to Project".
3.  Hovering over it reveals a list of projects.
4.  Selecting a project updates all activities under that row (cascading update).
5.  The view should refresh (reactive to SwiftData changes) to reflect the new grouping.
