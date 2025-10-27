import SwiftUI

import os
struct SidebarView: View {
    @State private var isMyProjectsExpanded: Bool = true
    @State private var showingCreateProject = false
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var projectManager: ProjectManager

    var body: some View {
        List(selection: $appState.selectedSidebar) {
            Section {
                NavigationLink(value: "Activities") {
                    Label("Activities", systemImage: "clock")
                }
                NavigationLink(value: "Stats") {
                    Label("Stats", systemImage: "chart.bar")
                }
                NavigationLink(value: "Reports") {
                    Label("Reports", systemImage: "doc.text")
                }
            }
            
            Section(header: Text("Projects")) {
                HStack {
                    Label("All Activities", systemImage: "tray.full")
                    Spacer()
                    Text("37m")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                .contentShape(Rectangle())
                .background(appState.isSpecialItemSelected("All Activities") ? Color.accentColor.opacity(0.2) : Color.clear)
                .onTapGesture {
                    appState.selectSpecialItem("All Activities")
                }
                
                HStack {
                    Label("Unassigned", systemImage: "questionmark.circle")
                    Spacer()
                    Text("37m")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                .contentShape(Rectangle())
                .background(appState.isSpecialItemSelected("Unassigned") ? Color.accentColor.opacity(0.2) : Color.clear)
                .onTapGesture {
                    appState.selectSpecialItem("Unassigned")
                }
                
                DisclosureGroup(isExpanded: $isMyProjectsExpanded) {
                    ForEach(projectManager.buildProjectTree()) { project in
                        ProjectRowView(project: project, level: 0)
                    }
                    .onMove(perform: moveProjects)
                    .deleteDisabled(true)
                } label: {
                    HStack {
                        Image(systemName: "folder")
                        Text("My Projects")
                        Spacer()
                        Button(action: { 
                            showingCreateProject = true 
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Create New Project")
                        .accessibilityHint("Creates a new project at the root level")
                        .help("Create New Project")
                    }
                    .contentShape(Rectangle())
                    .background(appState.isSpecialItemSelected("My Projects") ? Color.accentColor.opacity(0.2) : Color.clear)
                    .onTapGesture {
                        appState.selectSpecialItem("My Projects")
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Time Tracker")
        .sheet(isPresented: $showingCreateProject) {
            EditProjectView(mode: .create(parentID: nil), isPresented: $showingCreateProject)
        }
        .onAppear {
            
            Task {
                do {
                    try await projectManager.loadProjects()
                    appState.validateCurrentSelection()
                } catch {
                    Logger.ui.error("️ Failed to load projects: \(error.localizedDescription)")
                }
            }
        }
        .onReceive(projectManager.$projects) { projects in
            
            appState.validateCurrentSelection()
        }
        .onReceive(NotificationCenter.default.publisher(for: .projectDidChange)) { notification in
            if let changedProject = notification.object as? Project {
                Logger.ui.info("Project changed: \(changedProject.name)")
            }
            appState.validateCurrentSelection()
        }
    }
    
    private func moveProjects(from source: IndexSet, to destination: Int) {
        let rootProjects = projectManager.buildProjectTree()
        
        Task {
            do {
                for index in source {
                    if index < rootProjects.count {
                        let project = rootProjects[index]
                        let newIndex = destination > index ? destination - 1 : destination
                        try await projectManager.reorderProject(project, to: newIndex, in: nil)
                    }
                }
            } catch {
                Logger.ui.error("️ Failed to move project: \(error.localizedDescription)")
            }
        }
    }
}
