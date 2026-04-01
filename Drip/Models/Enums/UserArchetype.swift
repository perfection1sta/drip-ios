import SwiftUI

enum UserArchetype: String, Codable, CaseIterable, Identifiable {
    case gymBro           = "gymBro"
    case functionalFitness = "functionalFitness"
    case pilatesYoga      = "pilatesYoga"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gymBro:            return "Gym"
        case .functionalFitness: return "Functional"
        case .pilatesYoga:       return "Pilates & Yoga"
        }
    }

    var tagline: String {
        switch self {
        case .gymBro:            return "Build strength & size with classic lifts"
        case .functionalFitness: return "Move better with circuits & compound work"
        case .pilatesYoga:       return "Tone, lengthen & restore through flow"
        }
    }

    var iconName: String {
        switch self {
        case .gymBro:            return "dumbbell.fill"
        case .functionalFitness: return "figure.strengthtraining.functional"
        case .pilatesYoga:       return "figure.mind.and.body"
        }
    }

    var accentColor: Color {
        switch self {
        case .gymBro:            return .archetypeGymBro
        case .functionalFitness: return .archetypeFunctional
        case .pilatesYoga:       return .archetypePilates
        }
    }

    var defaultWorkoutStyle: WorkoutStyle {
        switch self {
        case .gymBro:            return .setsAndReps
        case .functionalFitness: return .circuit
        case .pilatesYoga:       return .flowSequence
        }
    }

    var defaultEquipment: [Equipment] {
        switch self {
        case .gymBro:
            return [.barbell, .dumbbells, .cableMachine, .bench, .pullUpBar]
        case .functionalFitness:
            return [.dumbbells, .kettlebell, .pullUpBar, .resistanceBands, .plyoBox]
        case .pilatesYoga:
            return [.yogaMat, .resistanceBands, .foamRoller]
        }
    }

    var defaultGoals: [FitnessGoal] {
        switch self {
        case .gymBro:            return [.buildMuscle, .improveStrength]
        case .functionalFitness: return [.endurance, .generalFitness]
        case .pilatesYoga:       return [.flexibility, .toning]
        }
    }
}
