import SwiftUI
import SwiftData

@Observable
final class SettingsViewModel {
    var profile: UserProfile?
    var notificationTime: Date = Calendar.current.date(
        bySettingHour: 7, minute: 0, second: 0, of: Date()
    ) ?? Date()
    var showDeleteConfirm = false
    var showArchetypeChangePicker = false

    // API key (mirrors Keychain state)
    var apiKeyInput: String = ""
    var hasAPIKey: Bool = false

    func load(context: ModelContext) {
        let descriptor = FetchDescriptor<UserProfile>()
        profile = (try? context.fetch(descriptor))?.first
        if let p = profile {
            var comps = DateComponents()
            comps.hour = p.preferredNotificationHour
            comps.minute = p.preferredNotificationMinute
            notificationTime = Calendar.current.date(from: comps) ?? notificationTime
        }
        hasAPIKey = KeychainService.hasAPIKey
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

    // MARK: - V2 Methods

    func toggleAICoach(_ enabled: Bool, context: ModelContext) {
        profile?.aiCoachEnabled = enabled
        try? context.save()
    }

    func saveAPIKey() {
        let key = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if key.isEmpty {
            KeychainService.delete(for: .claudeAPIKey)
            hasAPIKey = false
        } else {
            KeychainService.save(key, for: .claudeAPIKey)
            hasAPIKey = true
        }
        apiKeyInput = ""
    }

    func removeAPIKey() {
        KeychainService.delete(for: .claudeAPIKey)
        hasAPIKey = false
    }

    func changeArchetype(_ newArchetype: UserArchetype, context: ModelContext) {
        profile?.archetype = newArchetype
        SwiftDataService.shared.reseedForArchetype(newArchetype, context: context)
        try? context.save()
    }

    func redoOnboarding(context: ModelContext) {
        profile?.hasCompletedOnboarding = false
        try? context.save()
    }

    func deleteAllData(context: ModelContext) {
        SwiftDataService.shared.deleteAllData(context: context)
    }

    func exportWorkoutHistory(context: ModelContext) -> URL? {
        var descriptor = FetchDescriptor<WorkoutSession>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        let sessions = (try? context.fetch(descriptor)) ?? []

        let records = sessions.map { s -> [String: Any] in
            [
                "workoutName": s.workoutName,
                "date": ISO8601DateFormatter().string(from: s.startDate),
                "durationMinutes": s.totalDurationSeconds / 60,
                "volumeLbs": Int(s.totalVolumeLbs),
                "completionPercent": Int(s.completionPercentage * 100),
                "caloriesBurned": Int(s.caloriesBurned)
            ]
        }

        guard let data = try? JSONSerialization.data(withJSONObject: records, options: .prettyPrinted) else { return nil }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("drip_history.json")
        try? data.write(to: url)
        return url
    }
}
