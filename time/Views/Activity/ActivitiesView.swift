import SwiftData
import SwiftUI

/// Main view displaying activities in a hierarchical, collapsible structure
struct ActivitiesView: View {
    let activities: [Activity]

    @State private var hierarchyGroups: [ActivityHierarchyGroup] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if activities.isEmpty {
                emptyState
            } else {
                // Hierarchical list
                List {
                    ForEach(hierarchyGroups, id: \.id) { group in
                        HierarchicalActivityRow(group: group)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
        }
        .onAppear {
            buildHierarchy()
        }
        .onChange(of: activities) {
            buildHierarchy()
        }
    }

    // MARK: - Views

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No activities recorded")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Activities will appear here as you switch between apps")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.controlBackgroundColor))
    }

    private func buildHierarchy() {
        hierarchyGroups = ActivityDataProcessor.buildAppHierarchy(activities: activities)
    }
}

#Preview {
    ActivitiesView(activities: [])
        .modelContainer(for: Activity.self, inMemory: true)
}
