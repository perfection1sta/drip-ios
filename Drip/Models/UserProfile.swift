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

    // MARK: V2 — Archetype & Onboarding
    var archetypeRaw: String = "gymBro"
    var hasCompletedOnboarding: Bool = false
    var injuriesRaw: [String] = []
    var injuryNotes: String = ""
    var availableEquipmentRaw: [String] = []
    var fitnessGoalsRaw: [String] = []
    var preferredWorkoutDaysRaw: [Int] = []
    var aiCoachEnabled: Bool = false

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
        self.archetypeRaw = UserArchetype.gymBro.rawValue
        self.hasCompletedOnboarding = false
        self.injuriesRaw = []
        self.injuryNotes = ""
        self.availableEquipmentRaw = []
        self.fitnessGoalsRaw = []
        self.preferredWorkoutDaysRaw = [2, 3, 4, 5] // Mon-Thu default
        self.aiCoachEnabled = false
    }

    // MARK: Computed
    var fitnessLevel: DifficultyLevel {
        get { DifficultyLevel(rawValue: fitnessLevelRaw) ?? .intermediate }
        set { fitnessLevelRaw = newValue.rawValue }
    }
    var focusMuscleGroups: [MuscleGroup] {
        get { focusMuscleGroupsRaw.compactMap { MuscleGroup(rawValue: $0) } }
        set { focusMuscleGroupsRaw = newValue.map(\.rawValue) }
    }
    var archetype: UserArchetype {
        get { UserArchetype(rawValue: archetypeRaw) ?? .gymBro }
        set { archetypeRaw = newValue.rawValue }
    }
    var injuries: [InjuryArea] {
        get { injuriesRaw.compactMap { InjuryArea(rawValue: $0) } }
        set { injuriesRaw = newValue.map(\.rawValue) }
    }
    var availableEquipment: [Equipment] {
        get { availableEquipmentRaw.compactMap { Equipment(rawValue: $0) } }
        set { availableEquipmentRaw = newValue.map(\.rawValue) }
    }
    var fitnessGoals: [FitnessGoal] {
        get { fitnessGoalsRaw.compactMap { FitnessGoal(rawValue: $0) } }
        set { fitnessGoalsRaw = newValue.map(\.rawValue) }
    }
}
