import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var exerciseDescription: String
    var instructions: [String]
    var tips: [String]
    var primaryMusclesRaw: [String]
    var secondaryMusclesRaw: [String]
    var categoryRaw: String
    var difficultyRaw: String
    var equipment: String
    var defaultSets: Int
    var defaultReps: Int
    var defaultDurationSeconds: Int?
    var restDurationSeconds: Int
    var iconName: String
    var caloriesPerMinute: Double

    // MARK: V2 — Archetype & Style
    var archetypeRaw: String = "gymBro"
    var workoutStyleRaw: String = "setsAndReps"
    var defaultHoldSeconds: Int?   // for timed holds (pilates/yoga)

    init(id: UUID = UUID(),
         name: String,
         description: String,
         instructions: [String],
         tips: [String] = [],
         primaryMuscles: [MuscleGroup],
         secondaryMuscles: [MuscleGroup] = [],
         category: ExerciseCategory,
         difficulty: DifficultyLevel,
         equipment: String,
         defaultSets: Int? = nil,
         defaultReps: Int? = nil,
         defaultDurationSeconds: Int? = nil,
         defaultHoldSeconds: Int? = nil,
         restDurationSeconds: Int? = nil,
         iconName: String,
         caloriesPerMinute: Double = 6.0,
         archetype: UserArchetype = .gymBro,
         workoutStyle: WorkoutStyle = .setsAndReps) {
        self.id = id
        self.name = name
        self.exerciseDescription = description
        self.instructions = instructions
        self.tips = tips
        self.primaryMusclesRaw = primaryMuscles.map(\.rawValue)
        self.secondaryMusclesRaw = secondaryMuscles.map(\.rawValue)
        self.categoryRaw = category.rawValue
        self.difficultyRaw = difficulty.rawValue
        self.equipment = equipment
        self.defaultSets = defaultSets ?? difficulty.defaultSets
        self.defaultReps = defaultReps ?? difficulty.defaultReps
        self.defaultDurationSeconds = defaultDurationSeconds
        self.defaultHoldSeconds = defaultHoldSeconds
        self.restDurationSeconds = restDurationSeconds ?? difficulty.restSeconds
        self.iconName = iconName
        self.caloriesPerMinute = caloriesPerMinute
        self.archetypeRaw = archetype.rawValue
        self.workoutStyleRaw = workoutStyle.rawValue
    }

    // MARK: Computed
    var primaryMuscles: [MuscleGroup] {
        primaryMusclesRaw.compactMap { MuscleGroup(rawValue: $0) }
    }
    var secondaryMuscles: [MuscleGroup] {
        secondaryMusclesRaw.compactMap { MuscleGroup(rawValue: $0) }
    }
    var category: ExerciseCategory {
        ExerciseCategory(rawValue: categoryRaw) ?? .strength
    }
    var difficulty: DifficultyLevel {
        DifficultyLevel(rawValue: difficultyRaw) ?? .intermediate
    }
    var archetype: UserArchetype {
        UserArchetype(rawValue: archetypeRaw) ?? .gymBro
    }
    var workoutStyle: WorkoutStyle {
        WorkoutStyle(rawValue: workoutStyleRaw) ?? .setsAndReps
    }
    var isBodyweight: Bool { equipment.lowercased() == "bodyweight" }
    var isTimeBased: Bool { defaultHoldSeconds != nil || defaultDurationSeconds != nil }
}
