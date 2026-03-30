import Foundation
import SwiftData

@Model
final class WorkoutSet {
    var id: UUID
    var setNumber: Int
    var exerciseID: UUID
    var exerciseName: String
    var targetReps: Int
    var completedReps: Int
    var weightLbs: Double
    var isCompleted: Bool
    var completedAt: Date?
    var restTakenSeconds: Int

    init(setNumber: Int,
         exerciseID: UUID,
         exerciseName: String,
         targetReps: Int,
         weightLbs: Double = 0) {
        self.id = UUID()
        self.setNumber = setNumber
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.targetReps = targetReps
        self.completedReps = 0
        self.weightLbs = weightLbs
        self.isCompleted = false
        self.completedAt = nil
        self.restTakenSeconds = 0
    }

    var volume: Double { weightLbs * Double(completedReps) }
}
