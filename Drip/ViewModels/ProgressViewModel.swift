import SwiftUI
import SwiftData

@Observable
final class ProgressViewModel {
    struct DailyVolume: Identifiable {
        let id = UUID()
        var date: Date
        var volumeLbs: Double
        var sessionCount: Int
    }

    struct CalendarDay: Identifiable {
        let id = UUID()
        var date: Date
        var hasWorkout: Bool
        var isToday: Bool
    }

    enum TimeRange: String, CaseIterable {
        case week = "7D"
        case month = "30D"
        case threeMonths = "90D"
    }

    var weeklyVolume: [DailyVolume] = []
    var calendarDays: [CalendarDay] = []
    var personalRecords: [PersonalRecord] = []
    var sessionHistory: [WorkoutSession] = []
    var selectedTimeRange: TimeRange = .month

    var totalWorkouts: Int = 0
    var totalVolumeLbs: Double = 0
    var avgSessionMinutes: Double = 0

    func load(context: ModelContext, range: TimeRange? = nil) {
        let r = range ?? selectedTimeRange
        selectedTimeRange = r
        loadChartData(context: context, range: r)
        loadCalendarData(context: context)
        loadPersonalRecords(context: context)
        loadSessionHistory(context: context)
        loadSummary(context: context)
    }

    private func loadChartData(context: ModelContext, range: TimeRange) {
        let days: Int
        switch range {
        case .week: days = 7
        case .month: days = 30
        case .threeMonths: days = 90
        }

        let start = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.startDate >= start && $0.endDate != nil },
            sortBy: [SortDescriptor(\.startDate)]
        )
        let sessions = (try? context.fetch(descriptor)) ?? []

        // Build daily buckets
        var volumeByDay: [Date: (Double, Int)] = [:]
        for session in sessions {
            let day = Calendar.current.startOfDay(for: session.startDate)
            let current = volumeByDay[day] ?? (0, 0)
            volumeByDay[day] = (current.0 + session.totalVolumeLbs, current.1 + 1)
        }

        weeklyVolume = (0..<days).map { offset -> DailyVolume in
            let date = Calendar.current.date(
                byAdding: .day, value: -(days - 1 - offset), to: Calendar.current.startOfDay(for: Date())
            )!
            let data = volumeByDay[date] ?? (0, 0)
            return DailyVolume(date: date, volumeLbs: data.0, sessionCount: data.1)
        }
    }

    private func loadCalendarData(context: ModelContext) {
        let today = Calendar.current.startOfDay(for: Date())
        let monthStart = Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: today)
        )!
        let range = Calendar.current.range(of: .day, in: .month, for: today)!
        let daysInMonth = range.count

        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.startDate >= monthStart && $0.endDate != nil }
        )
        let sessions = (try? context.fetch(descriptor)) ?? []
        let workoutDays = Set(sessions.map {
            Calendar.current.startOfDay(for: $0.startDate)
        })

        calendarDays = (0..<daysInMonth).map { i in
            let date = Calendar.current.date(byAdding: .day, value: i, to: monthStart)!
            return CalendarDay(
                date: date,
                hasWorkout: workoutDays.contains(date),
                isToday: date == today
            )
        }
    }

    private func loadPersonalRecords(context: ModelContext) {
        let descriptor = FetchDescriptor<PersonalRecord>(
            sortBy: [SortDescriptor(\.achievedDate, order: .reverse)]
        )
        personalRecords = (try? context.fetch(descriptor)) ?? []
    }

    private func loadSessionHistory(context: ModelContext) {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.endDate != nil },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        descriptor.fetchLimit = 20
        sessionHistory = (try? context.fetch(descriptor)) ?? []
    }

    private func loadSummary(context: ModelContext) {
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.endDate != nil }
        )
        let all = (try? context.fetch(descriptor)) ?? []
        totalWorkouts = all.count
        totalVolumeLbs = all.reduce(0) { $0 + $1.totalVolumeLbs }
        let totalSeconds = all.reduce(0) { $0 + $1.totalDurationSeconds }
        avgSessionMinutes = all.isEmpty ? 0 : Double(totalSeconds) / Double(all.count) / 60.0
    }
}
