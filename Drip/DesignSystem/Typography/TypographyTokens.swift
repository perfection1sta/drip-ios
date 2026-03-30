import SwiftUI

// MARK: - Typography Tokens
// All type styles for the Drip design system.

extension Font {
    // Display — SF Pro Display, hero numbers
    static let displayLarge  = Font.system(size: 40, weight: .bold,      design: .default)
    static let displayMedium = Font.system(size: 32, weight: .bold,      design: .default)
    static let displaySmall  = Font.system(size: 28, weight: .bold,      design: .default)

    // Title
    static let titleLarge    = Font.system(size: 24, weight: .semibold,  design: .default)
    static let titleMedium   = Font.system(size: 20, weight: .semibold,  design: .default)
    static let titleSmall    = Font.system(size: 17, weight: .semibold,  design: .default)

    // Body
    static let bodyLarge     = Font.system(size: 17, weight: .regular,   design: .default)
    static let bodyMedium    = Font.system(size: 15, weight: .regular,   design: .default)
    static let bodySmall     = Font.system(size: 13, weight: .regular,   design: .default)

    // Label / Chip
    static let labelLarge    = Font.system(size: 13, weight: .medium,    design: .default)
    static let labelSmall    = Font.system(size: 11, weight: .medium,    design: .default)
    static let caption       = Font.system(size: 11, weight: .regular,   design: .default)

    // Numeric — always monospaced for counters and timers
    static let timerDisplay  = Font.system(size: 64, weight: .thin).monospacedDigit()
    static let timerMedium   = Font.system(size: 40, weight: .light).monospacedDigit()
    static let statNumber    = Font.system(size: 36, weight: .bold).monospacedDigit()
    static let statSmall     = Font.system(size: 24, weight: .semibold).monospacedDigit()
}
