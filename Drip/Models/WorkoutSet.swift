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

    // MARK: V2 — Timed holds (pilates/yoga) and circuit round tracking
    var isTimeBased: Bool = false
    var targetHoldSeconds: Int?    // target duration for holds
    var completedHoldSeconds: Int? // actual duration held
    var circuitRound: Int = 1

    init(setNumber: Int,
         exerciseID: UUID,
         exerciseName: String,
         targetReps: Int,
         weightLbs: Double = 0,
         isTimeBased: Bool = false,
         targetHoldSeconds: Int? = nil,
         circuitRound: Int = 1) {
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
        self.isTimeBased = isTimeBased
        self.targetHoldSeconds = targetHoldSeconds
        self.completedHoldSeconds = nil
        self.circuitRound = circuitRound
    }

    var volume: Double { weightLbs * Double(completedReps) }
}
