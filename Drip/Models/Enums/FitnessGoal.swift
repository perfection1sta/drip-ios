import Foundation

enum FitnessGoal: String, Codable, CaseIterable, Identifiable {
    case buildMuscle      = "buildMuscle"
    case loseWeight       = "loseWeight"
    case improveStrength  = "improveStrength"
    case flexibility      = "flexibility"
    case toning           = "toning"
    case endurance        = "endurance"
    case generalFitness   = "generalFitness"
    case injuryRecovery   = "injuryRecovery"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .buildMuscle:     return "Build Muscle"
        case .loseWeight:      return "Lose Weight"
        case .improveStrength: return "Get Stronger"
        case .flexibility:     return "Improve Flexibility"
        case .toning:          return "Tone & Define"
        case .endurance:       return "Build Endurance"
        case .generalFitness:  return "General Fitness"
        case .injuryRecovery:  return "Injury Recovery"
        }
    }

    var iconName: String {
        switch self {
        case .buildMuscle:     return "arrow.up.forward.circle.fill"
        case .loseWeight:      return "scalemass.fill"
        case .improveStrength: return "bolt.fill"
        case .flexibility:     return "figure.flexibility"
        case .toning:          return "waveform.path.ecg"
        case .endurance:       return "heart.fill"
        case .generalFitness:  return "star.fill"
        case .injuryRecovery:  return "cross.fill"
        }
    }

    var relevantArchetypes: [UserArchetype] {
        switch self {
        case .buildMuscle:     return [.gymBro]
        case .loseWeight:      return [.gymBro, .functionalFitness, .pilatesYoga]
        case .improveStrength: return [.gymBro, .functionalFitness]
        case .flexibility:     return [.pilatesYoga, .functionalFitness]
        case .toning:          return [.pilatesYoga]
        case .endurance:       return [.functionalFitness]
        case .generalFitness:  return [.gymBro, .functionalFitness, .pilatesYoga]
        case .injuryRecovery:  return [.pilatesYoga, .functionalFitness]
        }
    }
}
