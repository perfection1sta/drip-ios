import SwiftUI
import SwiftData

@Observable
final class SettingsViewModel {
    var profile: UserProfile?
    var notificationTime: Date = Calendar.current.date(
        bySettingHour: 7, minute: 0, second: 0, of: Date()
    ) ?? Date()

    func load(context: ModelContext) {
        let descriptor = FetchDescriptor<UserProfile>()
        profile = (try? context.fetch(descriptor))?.first
        if let p = profile {
            var comps = DateComponents()
            comps.hour = p.preferredNotificationHour
            comps.minute = p.preferredNotificationMinute
            notificationTime = Calendar.current.date(from: comps) ?? notificationTime
        }
    }

    func saveProfile(context: ModelContext) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        profile?.preferredNotificationHour = comps.hour ?? 7
        profile?.preferredNotificationMinute = comps.minute ?? 0
        try? context.save()
    }

    func toggleNotifications(_ enabled: Bool, context: ModelContext) {
        profile?.notificationsEnabled = enabled
        if enabled {
            Task { await NotificationService.shared.scheduleWorkoutReminder(at: notificationTime) }
        } else {
            NotificationService.shared.cancelAll()
        }
        try? context.save()
    }

    func updateDifficulty(_ level: DifficultyLevel, context: ModelContext) {
        profile?.fitnessLevel = level
        try? context.save()
    }

    func updateWeeklyGoal(_ days: Int, context: ModelContext) {
        profile?.weeklyGoalDays = days
        try? context.save()
    }
}
