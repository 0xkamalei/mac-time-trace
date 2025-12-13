import SwiftData
import SwiftUI

enum TimelineScale: String, CaseIterable, Identifiable {
    case hours
    case days
    case weeks
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .hours: return "Hours"
        case .days: return "Days"
        case .weeks: return "Weeks"
        }
    }
}

class TimelineViewModel: ObservableObject {
    @Published var selectedDateRange: AppDateRange
    @Published var timeScale: TimelineScale = .hours
    @Published var timelineScale: CGFloat = 1.0
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private var modelContext: ModelContext?
    
    init() {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        self.selectedDateRange = AppDateRange(startDate: startOfDay, endDate: endOfDay)
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func getTimelineWidth() -> CGFloat {
        return 1000 * timelineScale
    }
    
    func getTotalWidth() -> CGFloat {
        return 1200 * timelineScale
    }
    
    func timeToPosition(_ date: Date) -> Double {
        let totalDuration = selectedDateRange.endDate.timeIntervalSince(selectedDateRange.startDate)
        guard totalDuration > 0 else { return 0 }
        let elapsed = date.timeIntervalSince(selectedDateRange.startDate)
        return max(0, min(1, elapsed / totalDuration))
    }
    
    func durationToWidth(_ duration: TimeInterval) -> Double {
        let totalDuration = selectedDateRange.endDate.timeIntervalSince(selectedDateRange.startDate)
        guard totalDuration > 0 else { return 0 }
        return duration / totalDuration
    }
}
