import AppKit // Added AppKit import to access NSColor
import SwiftUI

struct TimelineView: View {
    @State private var timelineScale: CGFloat = 1.0
    
    private var timelineWidth: CGFloat {
        return 1920 * timelineScale
    }
    
    private var totalWidth: CGFloat {
        return 140 + timelineWidth
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            VStack(spacing: 12) {
                // Time header
                HStack(alignment: .bottom, spacing: 0) {
                    Text("TIME")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 140, alignment: .leading)
                        .padding(.leading, 16)
                    
                    ForEach(["00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", "07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"], id: \.self) { time in
                        Text(time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 80 * timelineScale)
                    }
                }
                .padding(.bottom, 4)
                .padding(.top, 4)
                
                // Device row
                HStack(alignment: .center, spacing: 0) {
                    Text("MACBOOK PRO INTEL i9")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 140, alignment: .leading)
                        .padding(.leading, 16)
                    
                    // Timeline blocks
                    ZStack(alignment: .leading) {
                        // Background timeline
                        Rectangle()
                            .fill(Color(NSColor.systemGray))
                            .frame(width: timelineWidth, height: 24) // 24 hours * 80px per hour
                        
                        // Activity blocks - would be dynamic in real app
                        Group {
                            TimeBlock(color: .blue.opacity(0.5), position: 0.05, width: 0.02)
                            TimeBlock(color: .green.opacity(0.5), position: 0.15, width: 0.02)
                            TimeBlock(color: .green.opacity(0.5), position: 0.22, width: 0.03)
                            TimeBlock(color: .green.opacity(0.8), position: 0.25, width: 0.02)
                            TimeBlock(color: .green.opacity(0.5), position: 0.35, width: 0.02)
                            TimeBlock(color: .green.opacity(0.5), position: 0.42, width: 0.02)
                            TimeBlock(color: .green.opacity(0.5), position: 0.48, width: 0.02)
                            TimeBlock(color: .green.opacity(0.8), position: 0.58, width: 0.02)
                            TimeBlock(color: .green.opacity(0.5), position: 0.65, width: 0.02)
                            TimeBlock(color: .green.opacity(0.5), position: 0.78, width: 0.02)
                            TimeBlock(color: .blue.opacity(0.5), position: 0.82, width: 0.02)
                            TimeBlock(color: .green.opacity(0.5), position: 0.84, width: 0.05)
                            TimeBlock(color: .green.opacity(0.8), position: 0.95, width: 0.02)
                        }
                    }
                }
                
                // Project row
                HStack(alignment: .center, spacing: 0) {
                    Text("PROJECT")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 140, alignment: .leading)
                        .padding(.leading, 16)
                    
                    // Empty timeline
                    Rectangle()
                        .fill(Color(NSColor.systemGray))
                        .frame(width: timelineWidth, height: 24) // 24 hours * 80px per hour
                }
                
                // Time entries row
                HStack(alignment: .center, spacing: 0) {
                    Text("TIME ENTRIES")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 140, alignment: .leading)
                        .padding(.leading, 16)
                    
                    // Time entries blocks
                    ZStack(alignment: .leading) {
                        // Background timeline
                        Rectangle()
                            .fill(Color(NSColor.systemGray))
                            .frame(width: timelineWidth, height: 24) // 24 hours * 80px per hour
                        
                        // Entry blocks - would be dynamic in real app
                        Group {
                            TimeEntryBlock(position: 0.07, width: 0.1)
                            TimeEntryBlock(position: 0.21, width: 0.03)
                            TimeEntryBlock(position: 0.25, width: 0.02)
                            TimeEntryBlock(position: 0.28, width: 0.02)
                            TimeEntryBlock(position: 0.31, width: 0.15)
                            TimeEntryBlock(position: 0.5, width: 0.1)
                            TimeEntryBlock(position: 0.65, width: 0.2)
                            TimeEntryBlock(position: 0.89, width: 0.05)
                            TimeEntryBlock(position: 0.95, width: 0.04)
                        }
                    }
                }
            }
            .padding(.bottom)
        }
        .scrollIndicators(.visible, axes: .horizontal)
        .contentMargins(.horizontal, 0) // 确保内容边距不影响滚动
        .onZoom(scale: $timelineScale)
    }
}

struct TimeBlock: View {
    let color: Color
    let position: Double // 0-1 position on timeline
    let width: Double // 0-1 width on timeline
    
    var body: some View {
        GeometryReader { geo in
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: width * geo.size.width, height: 24)
                .position(x: position * geo.size.width, y: 12)
        }
        .frame(height: 24)
    }
}

struct TimeEntryBlock: View {
    let position: Double // 0-1 position on timeline
    let width: Double // 0-1 width on timeline
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: position * geo.size.width)
                
                Button(action: {}) {
                    ZStack {
                        Rectangle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: width * geo.size.width, height: 24)
                        
                        Text("+")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
        .frame(height: 24)
    }
}

#Preview {
    TimelineView()
}
