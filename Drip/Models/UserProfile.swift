import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var name: String
    var weeklyGoalDays: Int
    var fitnessLevelRaw: String
    var preferredWorkoutDurationMinutes: Int
    var focusMuscleGroupsRaw: [String]
    var notificationsEnabled: Bool
    var preferredNotificationHour: Int    // 0-23
    var preferredNotificationMinute: Int  // 0-59
    var joinDate: Date
    var totalWorkoutsCompleted: Int
    var currentStreakDays: Int
    var longestStreakDays: Int

    init(name: String = "Athlete") {
        self.id = UUID()
        self.name = name
        self.weeklyGoalDays = 4
        self.fitnessLevelRaw = DifficultyLevel.intermediate.rawValue
        self.preferredWorkoutDurationMinutes = 45
        self.focusMuscleGroupsRaw = []
        self.notificationsEnabled = false
        self.preferredNotificationHour = 7
        self.preferredNotificationMinute = 0
        self.joinDate = Date()
        self.totalWorkoutsCompleted = 0
        self.currentStreakDays = 0
        self.longestStreakDays = 0
    }

    var fitnessLevel: DifficultyLevel {
        get { DifficultyLevel(rawValue: fitnessLevelRaw) ?? .intermediate }
        set { fitnessLevelRaw = newValue.rawValue }
    }
    var focusMuscleGroups: [MuscleGroup] {
        get { focusMuscleGroupsRaw.compactMap { MuscleGroup(rawValue: $0) } }
        set { focusMuscleGroupsRaw = newValue.map(\.rawValue) }
    }
}
