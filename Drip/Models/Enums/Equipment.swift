import SwiftUI

enum Equipment: String, Codable, CaseIterable, Identifiable {
    case barbell        = "barbell"
    case dumbbells      = "dumbbells"
    case kettlebell     = "kettlebell"
    case pullUpBar      = "pullUpBar"
    case resistanceBands = "resistanceBands"
    case cableMachine   = "cableMachine"
    case yogaMat        = "yogaMat"
    case foamRoller     = "foamRoller"
    case plyoBox        = "plyoBox"
    case bench          = "bench"
    case ezBar          = "ezBar"
    case bodyweight     = "bodyweight"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .barbell:         return "Barbell"
        case .dumbbells:       return "Dumbbells"
        case .kettlebell:      return "Kettlebell"
        case .pullUpBar:       return "Pull-up Bar"
        case .resistanceBands: return "Resistance Bands"
        case .cableMachine:    return "Cable Machine"
        case .yogaMat:         return "Yoga Mat"
        case .foamRoller:      return "Foam Roller"
        case .plyoBox:         return "Plyo Box"
        case .bench:           return "Bench"
        case .ezBar:           return "EZ Bar"
        case .bodyweight:      return "Bodyweight Only"
        }
    }

    var iconName: String {
        switch self {
        case .barbell:         return "dumbbell.fill"
        case .dumbbells:       return "dumbbell"
        case .kettlebell:      return "figure.strengthtraining.functional"
        case .pullUpBar:       return "arrow.up.circle"
        case .resistanceBands: return "link"
        case .cableMachine:    return "cable.connector"
        case .yogaMat:         return "rectangle.fill"
        case .foamRoller:      return "cylinder.fill"
        case .plyoBox:         return "cube.fill"
        case .bench:           return "minus.rectangle.fill"
        case .ezBar:           return "waveform"
        case .bodyweight:      return "figure.stand"
        }
    }

    // Which archetypes typically use this equipment
    var relevantArchetypes: [UserArchetype] {
        switch self {
        case .barbell:         return [.gymBro]
        case .dumbbells:       return [.gymBro, .functionalFitness, .pilatesYoga]
        case .kettlebell:      return [.functionalFitness]
        case .pullUpBar:       return [.gymBro, .functionalFitness]
        case .resistanceBands: return [.functionalFitness, .pilatesYoga]
        case .cableMachine:    return [.gymBro]
        case .yogaMat:         return [.pilatesYoga, .functionalFitness]
        case .foamRoller:      return [.pilatesYoga]
        case .plyoBox:         return [.functionalFitness]
        case .bench:           return [.gymBro]
        case .ezBar:           return [.gymBro]
        case .bodyweight:      return [.gymBro, .functionalFitness, .pilatesYoga]
        }
    }
}
