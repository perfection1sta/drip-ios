import SwiftUI

// MARK: - Color Tokens
// All semantic colors for the Drip design system.
// Dark-first: every color is defined for dark mode,
// with light-mode variants via asset catalog.

extension Color {

    // MARK: Energy / Brand
    static let energyOrange  = Color(red: 1.0,   green: 0.420, blue: 0.208) // #FF6B35
    static let energyRed     = Color(red: 1.0,   green: 0.231, blue: 0.188) // #FF3B30
    static let wellnessTeal  = Color(red: 0.188, green: 0.835, blue: 0.784) // #30D5C8
    static let achieveGold   = Color(red: 1.0,   green: 0.839, blue: 0.039) // #FFD60A

    // MARK: Surfaces
    static let surfacePrimary   = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.051, green: 0.051, blue: 0.059, alpha: 1) // #0D0D0F
            : UIColor.systemGroupedBackground
    })

    static let surfaceSecondary = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.110, green: 0.110, blue: 0.118, alpha: 1) // #1C1C1E
            : UIColor.secondarySystemGroupedBackground
    })

    static let surfaceTertiary  = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.173, green: 0.173, blue: 0.180, alpha: 1) // #2C2C2E
            : UIColor.tertiarySystemGroupedBackground
    })

    static let surfaceGlass = Color.white.opacity(0.08)

    // MARK: Text
    static let textPrimary    = Color(UIColor.label)
    static let textSecondary  = Color(UIColor.secondaryLabel)
    static let textTertiary   = Color(UIColor.tertiaryLabel)

    // MARK: Semantic
    static let success = Color(red: 0.196, green: 0.843, blue: 0.294) // #32D74B
    static let warning = Color(red: 1.0,   green: 0.624, blue: 0.039) // #FF9F0A
    static let error   = Color(red: 1.0,   green: 0.271, blue: 0.227) // #FF453A

    // MARK: Archetype Accents
    static let archetypeGymBro    = Color(red: 1.0,   green: 0.420, blue: 0.208) // energyOrange
    static let archetypeFunctional = Color(red: 0.196, green: 0.898, blue: 0.369) // electric green
    static let archetypePilates   = Color(red: 0.788, green: 0.576, blue: 0.976) // soft lavender

    // MARK: Muscle Group
    static let muscleChest     = Color(red: 1.0,   green: 0.400, blue: 0.400) // coral
    static let muscleBack      = Color(red: 0.259, green: 0.522, blue: 0.957) // blue
    static let muscleLegs      = Color(red: 0.686, green: 0.322, blue: 0.871) // purple
    static let muscleCore      = Color(red: 1.0,   green: 0.588, blue: 0.0)   // amber
    static let muscleArms      = Color(red: 0.188, green: 0.835, blue: 0.784) // teal
    static let muscleShoulders = Color(red: 0.420, green: 0.549, blue: 0.961) // indigo
    static let muscleCardio    = Color(red: 1.0,   green: 0.420, blue: 0.208) // energy orange
    static let muscleFullBody  = Color(red: 0.196, green: 0.843, blue: 0.294) // green
}

// MARK: - ShapeStyle Extensions
// Allows dot-syntax token access in .foregroundStyle(), .fill(), etc.
// which expect a generic ShapeStyle rather than Color.

extension ShapeStyle where Self == Color {

    // Energy / Brand
    static var energyOrange:  Color { .energyOrange }
    static var energyRed:     Color { .energyRed }
    static var wellnessTeal:  Color { .wellnessTeal }
    static var achieveGold:   Color { .achieveGold }

    // Surfaces
    static var surfacePrimary:   Color { .surfacePrimary }
    static var surfaceSecondary: Color { .surfaceSecondary }
    static var surfaceTertiary:  Color { .surfaceTertiary }
    static var surfaceGlass:     Color { .surfaceGlass }

    // Text
    static var textPrimary:   Color { .textPrimary }
    static var textSecondary: Color { .textSecondary }
    static var textTertiary:  Color { .textTertiary }

    // Semantic
    static var success: Color { .success }
    static var warning: Color { .warning }
    static var error:   Color { .error }

    // Archetype Accents
    static var archetypeGymBro:    Color { .archetypeGymBro }
    static var archetypeFunctional: Color { .archetypeFunctional }
    static var archetypePilates:   Color { .archetypePilates }

    // Muscle Group
    static var muscleChest:     Color { .muscleChest }
    static var muscleBack:      Color { .muscleBack }
    static var muscleLegs:      Color { .muscleLegs }
    static var muscleCore:      Color { .muscleCore }
    static var muscleArms:      Color { .muscleArms }
    static var muscleShoulders: Color { .muscleShoulders }
    static var muscleCardio:    Color { .muscleCardio }
    static var muscleFullBody:  Color { .muscleFullBody }
}
