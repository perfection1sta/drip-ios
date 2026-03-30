import Foundation
import SwiftData

enum PRType: String, Codable {
    case maxWeight, maxReps, maxVolume
}

@Model
final class PersonalRecord {
    var id: UUID
    var exerciseID: UUID
    var exerciseName: String
    var achievedDate: Date
    var recordTypeRaw: String
    var value: Double
    var previousValue: Double

    init(exerciseID: UUID,
         exerciseName: String,
         recordType: PRType,
         value: Double,
         previousValue: Double = 0) {
        self.id = UUID()
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.achievedDate = Date()
        self.recordTypeRaw = recordType.rawValue
        self.value = value
        self.previousValue = previousValue
    }

    var recordType: PRType {
        PRType(rawValue: recordTypeRaw) ?? .maxWeight
    }

    var improvement: Double {
        guard previousValue > 0 else { return 0 }
        return ((value - previousValue) / previousValue) * 100
    }
}
