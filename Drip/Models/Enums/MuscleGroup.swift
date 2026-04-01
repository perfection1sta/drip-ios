import SwiftUI

enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    case chest, back, shoulders, biceps, triceps
    case core, glutes, quadriceps, hamstrings, calves
    case fullBody, cardio

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fullBody:   return "Full Body"
        case .quadriceps: return "Quads"
        case .hamstrings: return "Hamstrings"
        default:          return rawValue.capitalized
        }
    }

    var color: Color {
        switch self {
        case .chest:      return .muscleChest
        case .back:       return .muscleBack
        case .shoulders:  return .muscleShoulders
        case .biceps, .triceps: return .muscleArms
        case .core:       return .muscleCore
        case .glutes, .quadriceps, .hamstrings, .calves: return .muscleLegs
        case .fullBody:   return .muscleFullBody
        case .cardio:     return .muscleCardio
        }
    }

    var sfSymbol: String {
        switch self {
        case .chest:      return "figure.strengthtraining.traditional"
        case .back:       return "figure.walk"
        case .shoulders:  return "figure.arms.open"
        case .biceps:     return "figure.curling"
        case .triceps:    return "figure.gymnastics"
        case .core:       return "figure.core.training"
        case .glutes, .quadriceps, .hamstrings, .calves: return "figure.step.training"
        case .fullBody:   return "figure.mixed.cardio"
        case .cardio:     return "figure.run"
        }
    }
}
