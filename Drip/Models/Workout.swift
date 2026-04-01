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

    // MARK: V2 — Archetype & Style
    var archetypeRaw: String
    var workoutStyleRaw: String
    var isAIGenerated: Bool
    var circuitRounds: Int           // 1 for setsAndReps, 3-5 for circuits
    var aiPromptSummary: String?     // brief summary of AI prompt used (debug/transparency)

    @Relationship(deleteRule: .cascade)
    var workoutExercises: [WorkoutExercise]

    init(name: String,
         generatedDate: Date,
         estimatedDurationMinutes: Int,
         difficulty: DifficultyLevel,
         focusMuscles: [MuscleGroup],
         exercises: [WorkoutExercise],
         archetype: UserArchetype = .gymBro,
         workoutStyle: WorkoutStyle = .setsAndReps,
         isAIGenerated: Bool = false,
         circuitRounds: Int = 1) {
        self.id = UUID()
        self.name = name
        self.generatedDate = generatedDate
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.difficultyRaw = difficulty.rawValue
        self.focusMusclesRaw = focusMuscles.map(\.rawValue)
        self.statusRaw = WorkoutStatus.pending.rawValue
        self.isCompleted = false
        self.workoutExercises = exercises
        self.archetypeRaw = archetype.rawValue
        self.workoutStyleRaw = workoutStyle.rawValue
        self.isAIGenerated = isAIGenerated
        self.circuitRounds = circuitRounds
        self.aiPromptSummary = nil
    }

    // MARK: Computed
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
    var archetype: UserArchetype {
        UserArchetype(rawValue: archetypeRaw) ?? .gymBro
    }
    var workoutStyle: WorkoutStyle {
        WorkoutStyle(rawValue: workoutStyleRaw) ?? .setsAndReps
    }
    var sortedExercises: [WorkoutExercise] {
        workoutExercises.sorted { $0.sortOrder < $1.sortOrder }
    }
}
