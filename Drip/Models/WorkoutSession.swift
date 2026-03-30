import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var id: UUID
    var workoutID: UUID
    var workoutName: String
    var startDate: Date
    var endDate: Date?
    var totalDurationSeconds: Int
    var totalVolumeLbs: Double
    var caloriesBurned: Double
    var notes: String
    var completionPercentage: Double

    @Relationship(deleteRule: .cascade)
    var completedSets: [WorkoutSet]

    init(workoutID: UUID, workoutName: String) {
        self.id = UUID()
        self.workoutID = workoutID
        self.workoutName = workoutName
        self.startDate = Date()
        self.endDate = nil
        self.totalDurationSeconds = 0
        self.totalVolumeLbs = 0
        self.caloriesBurned = 0
        self.notes = ""
        self.completionPercentage = 0
        self.completedSets = []
    }

    var durationFormatted: String {
        let minutes = totalDurationSeconds / 60
        let seconds = totalDurationSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
