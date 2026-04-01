import SwiftUI

struct StreakCalendarView: View {
    let days: [ProgressViewModel.CalendarDay]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        DripCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("This Month")
                    .font(.titleSmall)
                    .foregroundStyle(.textPrimary)

                // Weekday headers
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(Array(weekdayLabels.enumerated()), id: \.offset) { _, d in
                        Text(d)
                            .font(.caption)
                            .foregroundStyle(.textTertiary)
                            .frame(maxWidth: .infinity)
                    }
                }

                // Day grid
                LazyVGrid(columns: columns, spacing: 4) {
                    // Leading padding for first day of month
                    if let firstDay = days.first?.date {
                        let weekday = Calendar.current.component(.weekday, from: firstDay)
                        ForEach(0..<(weekday - 1), id: \.self) { _ in
                            Color.clear.frame(height: 32)
                        }
                    }
                    ForEach(days) { day in
                        CalendarDayCell(day: day)
                    }
                }
            }
        }
    }
}

struct CalendarDayCell: View {
    let day: ProgressViewModel.CalendarDay

    var body: some View {
        ZStack {
            Circle()
                .fill(bgColor)
                .frame(height: 32)
            Text(day.date.dayNumber)
                .font(.labelSmall)
                .foregroundStyle(textColor)
        }
        .overlay(
            Circle()
                .strokeBorder(day.isToday ? Color.energyOrange : .clear, lineWidth: 2)
        )
    }

    private var bgColor: Color {
        if day.hasWorkout { return .energyOrange.opacity(0.8) }
        if day.isToday    { return .energyOrange.opacity(0.15) }
        return .surfaceTertiary.opacity(0.3)
    }

    private var textColor: Color {
        day.hasWorkout ? .white : (day.isToday ? .energyOrange : .textTertiary)
    }
}
