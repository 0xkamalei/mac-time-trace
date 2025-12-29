I will implement the "Merged Statistics" (合并统计) feature to optimize the timeline visualization for fragmented usage.

### 1. Settings Implementation
I will modify `GeneralSettingsView` in `time/Views/Settings/SettingsView.swift` to add a new "Timeline" section:
- **Toggle**: "Merge Fragmented Activities" (Controls `timelineMergeStatisticsEnabled`).
- **Stepper**: "Merge Interval" (Controls `timelineMergeIntervalHours`, default 1 hour).
- These settings will be persisted using `@AppStorage`.

### 2. Timeline Logic Implementation
I will update `TimelineProcessor.swift` to include a new processing mode `processMerged`:
- **Bucketing**: Divide the visible time range into fixed intervals (e.g., 1 hour).
- **Aggregation**: Within each interval, aggregate the duration of each app.
- **Visualization**: 
    - Sort apps by duration within the bucket.
    - Draw blocks sequentially filling the bucket's time range.
    - The width of each block will correspond to its total duration within that hour.
    - Ensure consistent colors using the existing hashing mechanism.
    - This creates a continuous, stacked-bar-like visualization for each hour.

### 3. View Integration
I will update `TimelineView.swift` to connect the settings and the processor:
- Observe the new `@AppStorage` settings.
- In the `recalculate` method, switch between the standard `process` and the new `processMerged` based on the user's preference.

This approach satisfies all requirements:
- Solves the fragmentation issue.
- Provides a "coarse summary" as requested.
- Continuous display with consistent colors.
- Configurable via Settings.
