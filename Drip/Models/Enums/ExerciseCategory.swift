import SwiftUI

enum ExerciseCategory: String, Codable, CaseIterable, Identifiable {
    case strength, hypertrophy, cardio, mobility, hiit, recovery

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    var color: Color {
        switch self {
        case .strength:    return .energyRed
        case .hypertrophy: return .energyOrange
        case .cardio:      return .muscleCardio
        case .mobility:    return .wellnessTeal
        case .hiit:        return .achieveGold
        case .recovery:    return .success
        }
    }

    var sfSymbol: String {
        switch self {
        case .strength:    return "dumbbell.fill"
        case .hypertrophy: return "figure.strengthtraining.traditional"
        case .cardio:      return "figure.run"
        case .mobility:    return "figure.flexibility"
        case .hiit:        return "bolt.fill"
        case .recovery:    return "leaf.fill"
        }
    }
}
