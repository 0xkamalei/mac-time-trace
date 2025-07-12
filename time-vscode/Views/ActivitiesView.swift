import SwiftUI

struct ActivitiesView: View {
    let activities: [Activity]
    @State private var sortMode: SortMode = .chronological
    @State private var expandedGroups: Set<String> = ["Google Chrome"] // Default expanded items
    
    enum SortMode: String, CaseIterable {
        case unfiled = "Unfiled"
        case category = "By Category"
        case chronological = "Chronological"
    }
    
    // Group activities based on app type
    var groupedActivities: [Activity] {
        // For this demo, we're keeping the same activities but marking browsers for special handling
        return activities
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("All Activities: 24m 56s")
                    .font(.headline)
                
                Spacer()
                
                Picker(selection: $sortMode, label: Image(systemName: "gearshape")) {
                    ForEach(SortMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 300)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            List {
                HStack {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary)
                        .frame(width: 24)
                    Text("(Unassigned)")
                        .font(.subheadline)
                    Spacer()
                    Text("24m")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .padding(.vertical, 4)
                .listRowInsets(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                
                ForEach(groupedActivities) { activity in
                    if activity.appName == "Google Chrome" {
                        // Special handling for browsers with foldable website list
                        DisclosureGroup(
                            isExpanded: Binding(
                                get: { expandedGroups.contains(activity.appName) },
                                set: { isExpanded in
                                    if isExpanded {
                                        expandedGroups.insert(activity.appName)
                                    } else {
                                        expandedGroups.remove(activity.appName)
                                    }
                                }
                            )
                        ) {
                            // Websites visited in this browser
                            Group {
                                HStack {
                                    Image(systemName: "globe")
                                        .frame(width: 24)
                                        .foregroundColor(.secondary)
                                    Text("developer.apple.com")
                                    Spacer()
                                    Text("<1m")
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 2)
                                .padding(.leading, 20) // Indent
                                
                                HStack {
                                    Image(systemName: "globe")
                                        .frame(width: 24)
                                        .foregroundColor(.secondary)
                                    Text("copilot.microsoft.com")
                                    Spacer()
                                    Text("<1m")
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 2)
                                .padding(.leading, 20) // Indent
                                
                                HStack {
                                    Image(systemName: "globe")
                                        .frame(width: 24)
                                        .foregroundColor(.secondary)
                                    Text("www.google.com")
                                    Spacer()
                                    Text("<1m")
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 2)
                                .padding(.leading, 20) // Indent
                            }
                        } label: {
                            HStack {
                                Image(systemName: activity.icon)
                                    .frame(width: 24)
                                Text(activity.appName)
                                Spacer()
                                Text(activity.duration)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    } else {
                        // Regular activities without folding
                        HStack {
                            Image(systemName: activity.icon)
                                .frame(width: 24)
                            Text(activity.appName)
                            Spacer()
                            Text(activity.duration)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    ActivitiesView(activities: [
        Activity(appName: "Xcode", duration: "5m", icon: "hammer", minutes: 5),
        Activity(appName: "Folo", duration: "5m", icon: "f.cursive", minutes: 5),
        Activity(appName: "Discord", duration: "4m", icon: "bubble.left.and.bubble.right", minutes: 4),
        Activity(appName: "GitHub Copilot for Xcode Extension", duration: "3m", icon: "chevron.left.forwardslash.chevron.right", minutes: 3),
        Activity(appName: "Microsoft Edge", duration: "1m", icon: "safari", minutes: 1),
        Activity(appName: "GitHub Copilot for Xcode", duration: "1m", icon: "chevron.left.forwardslash.chevron.right", minutes: 1),
        Activity(appName: "WeChat", duration: "1m", icon: "message", minutes: 1),
        Activity(appName: "time-vscode", duration: "<1m", icon: "clock", minutes: 0),
        Activity(appName: "Timing", duration: "<1m", icon: "clock", minutes: 0),
        Activity(appName: "App Store", duration: "<1m", icon: "app.badge", minutes: 0),
        Activity(appName: "Google Chrome", duration: "1m", icon: "globe", minutes: 1),
        Activity(appName: "Snipaste", duration: "<1m", icon: "scissors", minutes: 0)
    ])
}
