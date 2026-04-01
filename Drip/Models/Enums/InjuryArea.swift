import Foundation

enum InjuryArea: String, Codable, CaseIterable, Identifiable {
    case lowerBack  = "lowerBack"
    case shoulders  = "shoulders"
    case knees      = "knees"
    case wrists     = "wrists"
    case neck       = "neck"
    case hips       = "hips"
    case ankles     = "ankles"
    case elbows     = "elbows"
    case upperBack  = "upperBack"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lowerBack:  return "Lower Back"
        case .shoulders:  return "Shoulders"
        case .knees:      return "Knees"
        case .wrists:     return "Wrists"
        case .neck:       return "Neck"
        case .hips:       return "Hips"
        case .ankles:     return "Ankles"
        case .elbows:     return "Elbows"
        case .upperBack:  return "Upper Back"
        }
    }

    var iconName: String {
        switch self {
        case .lowerBack:  return "figure.walk"
        case .shoulders:  return "figure.arms.open"
        case .knees:      return "figure.run"
        case .wrists:     return "hand.raised.fill"
        case .neck:       return "person.fill"
        case .hips:       return "figure.stand"
        case .ankles:     return "shoe.fill"
        case .elbows:     return "arm.variable.and.arm.fill"
        case .upperBack:  return "figure.strengthtraining.traditional"
        }
    }

    // Exercises and movements to caution/avoid
    var exerciseCautions: String {
        switch self {
        case .lowerBack:
            return "Avoid heavy axial loading. Prioritise hip hinges with light weight, goblet squats, bird dogs, and core bracing cues."
        case .shoulders:
            return "Avoid overhead pressing behind the neck. Favour neutral-grip pressing, face pulls, and rotator cuff prehab."
        case .knees:
            return "Avoid deep knee flexion under load. Favour terminal knee extension, leg press with partial ROM, and step-ups."
        case .wrists:
            return "Avoid loaded wrist extension. Use neutral-grip or fist push-ups, straps for pulling, and wrist wraps for pressing."
        case .neck:
            return "Avoid neck flexion under load. No behind-the-neck exercises. Prioritise thoracic mobility and upper trap releases."
        case .hips:
            return "Avoid extreme ROM under load. Favour hip bridges, clamshells, and controlled hip hinge patterns."
        case .ankles:
            return "Avoid impact and unstable surfaces. Favour seated calf work, swimming pool movements, and upper-body focus."
        case .elbows:
            return "Avoid elbow extension under heavy load. Use neutral grips, reduce tricep extension volume, and favour cable work."
        case .upperBack:
            return "Avoid heavy rowing with rounded spine. Prioritise face pulls, band pull-aparts, and thoracic extension work."
        }
    }
}
