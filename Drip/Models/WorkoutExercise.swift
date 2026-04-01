import Foundation
import SwiftData

// MARK: - Workout Exercise (join model preserving order)
@Model
final class WorkoutExercise {
    var id: UUID
    var sortOrder: Int
    var customSets: Int?
    var customReps: Int?
    var exerciseID: UUID        // denormalised for fast lookup

    // Stored references
    var exerciseName: String
    var exerciseIconName: String
    var exercisePrimaryMusclesRaw: [String]
    var exerciseDifficultyRaw: String
    var exerciseCategoryRaw: String
    var exerciseEquipment: String
    var exerciseRestSeconds: Int
    var exerciseWorkoutStyleRaw: String = "setsAndReps"

    init(sortOrder: Int, exercise: Exercise, customSets: Int? = nil, customReps: Int? = nil) {
        self.id = UUID()
        self.sortOrder = sortOrder
        self.customSets = customSets
        self.customReps = customReps
        self.exerciseID = exercise.id
        self.exerciseName = exercise.name
        self.exerciseIconName = exercise.iconName
        self.exercisePrimaryMusclesRaw = exercise.primaryMusclesRaw
        self.exerciseDifficultyRaw = exercise.difficultyRaw
        self.exerciseCategoryRaw = exercise.categoryRaw
        self.exerciseEquipment = exercise.equipment
        self.exerciseRestSeconds = exercise.restDurationSeconds
        self.exerciseWorkoutStyleRaw = exercise.workoutStyleRaw
    }

    var sets: Int { customSets ?? DifficultyLevel(rawValue: exerciseDifficultyRaw)?.defaultSets ?? 3 }
    var reps: Int { customReps ?? DifficultyLevel(rawValue: exerciseDifficultyRaw)?.defaultReps ?? 10 }
    var primaryMuscles: [MuscleGroup] {
        exercisePrimaryMusclesRaw.compactMap { MuscleGroup(rawValue: $0) }
    }
    var workoutStyle: WorkoutStyle {
        WorkoutStyle(rawValue: exerciseWorkoutStyleRaw) ?? .setsAndReps
    }
}
