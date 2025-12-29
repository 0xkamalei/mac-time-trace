# Implement Auto Assign Activity to Project (with Caching)

I will implement the functionality to automatically assign activities to projects based on user-defined rules, using a cached `AutoAssignmentManager`.

## Data Model Changes

1.  **Create `AutoAssignRule` Model**:
    *   File: `time/Models/Project/AutoAssignRule.swift`
    *   Attributes: `id`, `ruleType` (enum: `.appBundleId`, `.titleKeyword`), `value` (String).
    *   Relationship: Belongs to `Project`.

2.  **Update `Project` Model**:
    *   File: `time/Models/Project/Project.swift`
    *   Add relationship: `@Relationship(deleteRule: .cascade) var rules: [AutoAssignRule] = []`

## Business Logic Changes (Optimized)

1.  **Create `AutoAssignmentManager`**:
    *   File: `time/Managers/AutoAssignmentManager.swift`
    *   **Pattern**: Singleton (`shared`).
    *   **Responsibility**: Manage rule caching and matching logic.
    *   **State**:
        *   `private var cachedProjects: [Project] = []` (Sorted by sortOrder)
    *   **Methods**:
        *   `func reloadRules(modelContext: ModelContext)`: Fetch all projects (including rules) and update cache.
        *   `func evaluate(activity: Activity) -> String?`: Efficiently match activity against cached rules.
            *   Iterate cached projects in order.
            *   For each project, check its rules.
            *   Return first matching Project ID.

2.  **Update `ActivityManager`**:
    *   In `trackAppSwitch`, call `AutoAssignmentManager.shared.evaluate(activity)`.
    *   If a project ID is returned, assign it to the new activity.

3.  **Update `ProjectManager`**:
    *   Add a method to trigger `AutoAssignmentManager` reload.
    *   Call this when projects are created/updated/deleted.

## UI Changes

1.  **Update `EditProjectView.swift`**:
    *   Add "Auto Assignment Rules" section.
    *   List existing rules.
    *   Add "Add Rule" interface.
    *   **App Selection**: Provide a list of running applications (`NSWorkspace.shared.runningApplications`) for easy selection, plus manual entry.
    *   **Keyword Entry**: Text field.
    *   On Save: Trigger rule reload via `ProjectManager`.

## Implementation Steps

1.  **Define Models**: Create `AutoAssignRule` and update `Project`.
2.  **Implement Manager**: Create `AutoAssignmentManager` with caching.
3.  **Implement UI**: Update `EditProjectView` to manage rules.
4.  **Integrate Logic**: Connect `ActivityManager` to `AutoAssignmentManager` and ensure cache invalidation.
5.  **Verify**: Compile and test.
