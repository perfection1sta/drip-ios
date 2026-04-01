import Foundation

enum WorkoutStyle: String, Codable, CaseIterable, Identifiable {
    case setsAndReps   = "setsAndReps"
    case circuit       = "circuit"
    case flowSequence  = "flowSequence"
    case amrap         = "amrap"
    case emom          = "emom"
    case timedHold     = "timedHold"
    case superset      = "superset"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .setsAndReps:  return "Sets & Reps"
        case .circuit:      return "Circuit"
        case .flowSequence: return "Flow Sequence"
        case .amrap:        return "AMRAP"
        case .emom:         return "EMOM"
        case .timedHold:    return "Timed Hold"
        case .superset:     return "Superset"
        }
    }

    var shortDescription: String {
        switch self {
        case .setsAndReps:  return "Classic sets with rest between"
        case .circuit:      return "Rotate through exercises, rest between rounds"
        case .flowSequence: return "Linked movements in a flowing sequence"
        case .amrap:        return "As many rounds as possible in the time cap"
        case .emom:         return "One exercise every minute on the minute"
        case .timedHold:    return "Hold positions for time"
        case .superset:     return "Two exercises back-to-back, then rest"
        }
    }

    var primaryArchetype: UserArchetype {
        switch self {
        case .setsAndReps:  return .gymBro
        case .circuit:      return .functionalFitness
        case .flowSequence: return .pilatesYoga
        case .amrap:        return .functionalFitness
        case .emom:         return .functionalFitness
        case .timedHold:    return .pilatesYoga
        case .superset:     return .gymBro
        }
    }

    // Whether individual exercises in this style use time (true) or reps (false)
    var isTimeBased: Bool {
        switch self {
        case .timedHold, .amrap, .emom: return true
        default: return false
        }
    }
}
