import SwiftUI
import SwiftData

@Observable
final class HomeViewModel {
    var todayWorkout: Workout?
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var weeklySessionCount: Int = 0
    var weeklyGoal: Int = 4
    var recentSessions: [WorkoutSession] = []
    var motivationalQuote: String = ""
    var isLoading: Bool = false

    private let quotes = [
        "Every rep counts. Every drop of sweat matters.",
        "You don't have to be extreme, just consistent.",
        "The hardest part is showing up. You're already here.",
        "Progress, not perfection.",
        "Your future self is watching. Make it proud.",
        "One workout closer to the best version of you.",
        "Discipline is just choosing between what you want now and what you want most.",
        "Sweat is just fat crying.",
        "The body achieves what the mind believes.",
        "Make yourself proud today."
    ]

    func load(context: ModelContext) {
        motivationalQuote = quotes.randomElement() ?? quotes[0]
        loadTodayWorkout(context: context)
        loadStreak(context: context)
        loadWeeklyProgress(context: context)
        loadRecentSessions(context: context)
    }

    func loadTodayWorkout(context: ModelContext) {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.generatedDate >= today && $0.generatedDate < tomorrow },
            sortBy: [SortDescriptor(\.generatedDate, order: .reverse)]
        )
        todayWorkout = (try? context.fetch(descriptor))?.first
    }

    func loadStreak(context: ModelContext) {
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.endDate != nil },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        guard let sessions = try? context.fetch(descriptor) else { return }

        var streak = 0
        var checking = Calendar.current.startOfDay(for: Date())
        let sessionDays = Set(sessions.compactMap { s -> Date? in
            guard let _ = s.endDate else { return nil }
            return Calendar.current.startOfDay(for: s.startDate)
        })

        while sessionDays.contains(checking) {
            streak += 1
            checking = Calendar.current.date(byAdding: .day, value: -1, to: checking)!
        }
        currentStreak = streak

        // Profile update
        let profileDesc = FetchDescriptor<UserProfile>()
        if let profile = (try? context.fetch(profileDesc))?.first {
            weeklyGoal = profile.weeklyGoalDays
            if streak > profile.longestStreakDays {
                profile.longestStreakDays = streak
            }
            profile.currentStreakDays = streak
            longestStreak = profile.longestStreakDays
        }
    }

    func loadWeeklyProgress(context: ModelContext) {
        let weekStart = Calendar.current.date(
            from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        )!
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.startDate >= weekStart && $0.endDate != nil }
        )
        weeklySessionCount = (try? context.fetch(descriptor))?.count ?? 0
    }

    func loadRecentSessions(context: ModelContext) {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.endDate != nil },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        descriptor.fetchLimit = 5
        recentSessions = (try? context.fetch(descriptor)) ?? []
    }
}
