import Foundation
import SwiftData

@Model
final class Workout {
    var id: UUID
    var name: String
    var generatedDate: Date
    var estimatedDurationMinutes: Int
    var difficultyRaw: String
    var focusMusclesRaw: [String]
    var statusRaw: String
    var isCompleted: Bool

    @Relationship(deleteRule: .cascade)
    var workoutExercises: [WorkoutExercise]

    init(name: String,
         generatedDate: Date,
         estimatedDurationMinutes: Int,
         difficulty: DifficultyLevel,
         focusMuscles: [MuscleGroup],
         exercises: [WorkoutExercise]) {
        self.id = UUID()
        self.name = name
        self.generatedDate = generatedDate
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.difficultyRaw = difficulty.rawValue
        self.focusMusclesRaw = focusMuscles.map(\.rawValue)
        self.statusRaw = WorkoutStatus.pending.rawValue
        self.isCompleted = false
        self.workoutExercises = exercises
    }

    var difficulty: DifficultyLevel {
        DifficultyLevel(rawValue: difficultyRaw) ?? .intermediate
    }
    var focusMuscles: [MuscleGroup] {
        focusMusclesRaw.compactMap { MuscleGroup(rawValue: $0) }
    }
    var status: WorkoutStatus {
        get { WorkoutStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }
    var sortedExercises: [WorkoutExercise] {
        workoutExercises.sorted { $0.sortOrder < $1.sortOrder }
    }
}
