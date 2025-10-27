import SwiftUI

struct ActivitiesView: View {
    let activities: [Activity]
    @State private var hierarchyGroups: [ActivityHierarchyGroup] = []
    @State private var totalDuration: TimeInterval = 0

    private let displayMode = "Unified"
    private let groupByProject = true

    @State private var includeTimeEntries = true
    @State private var includeAppUsage = true
    @State private var includeTitles = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("All Activities: \(formattedTotalDuration)")
                    .font(.headline)

                Spacer()

                Text(displayMode)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Capsule())
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 8)

            List {
                if hierarchyGroups.isEmpty {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                            .frame(width: 24)
                        Text("No activities found")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("0m 0s")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                    .listRowInsets(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                } else {
                    ForEach(hierarchyGroups) { group in
                        HierarchicalActivityRow(group: group)
                            .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 12))
                    }
                }
            }
            .listStyle(.plain)
        }
        .onAppear {
            buildHierarchy()
        }
        .onChange(of: activities) {
            buildHierarchy()
        }
    }

    // MARK: - Private Methods

    /// Builds the hierarchical structure using ActivityDataProcessor
    private func buildHierarchy() {
        hierarchyGroups = ActivityDataProcessor.buildHierarchy(
            activities: activities,
            timeEntries: MockData.timeEntries,
            projects: MockData.projects
        )

        totalDuration = ActivityDataProcessor.calculateTotalDurationForActivities(activities)
    }

    /// Formats the total duration for display in the header
    private var formattedTotalDuration: String {
        return ActivityDataProcessor.formatDuration(totalDuration)
    }
}

#Preview {
    ActivitiesView(activities: MockData.activities)
}
