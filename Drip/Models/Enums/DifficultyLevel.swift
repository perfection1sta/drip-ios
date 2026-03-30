import SwiftUI

enum DifficultyLevel: String, Codable, CaseIterable, Identifiable {
    case beginner, intermediate, advanced

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    var stars: Int {
        switch self {
        case .beginner:     return 1
        case .intermediate: return 2
        case .advanced:     return 3
        }
    }

    var color: Color {
        switch self {
        case .beginner:     return .success
        case .intermediate: return .warning
        case .advanced:     return .energyRed
        }
    }

    var defaultSets: Int {
        switch self {
        case .beginner:     return 3
        case .intermediate: return 4
        case .advanced:     return 5
        }
    }

    var defaultReps: Int {
        switch self {
        case .beginner:     return 10
        case .intermediate: return 8
        case .advanced:     return 6
        }
    }

    var restSeconds: Int {
        switch self {
        case .beginner:     return 90
        case .intermediate: return 75
        case .advanced:     return 60
        }
    }
}
