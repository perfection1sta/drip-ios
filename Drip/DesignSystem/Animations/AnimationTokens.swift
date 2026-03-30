import SwiftUI

// MARK: - Animation Tokens
// Spring presets for consistent motion across Drip.

extension Animation {
    /// Immediate, crisp feedback — buttons, chips, selections.
    static let snappy  = Animation.spring(response: 0.3, dampingFraction: 0.7)

    /// Playful celebration bounce — set completions, PRs, confetti.
    static let bouncy  = Animation.spring(response: 0.5, dampingFraction: 0.6)

    /// Smooth data transitions — progress bars, chart updates.
    static let smooth  = Animation.spring(response: 0.6, dampingFraction: 0.8)

    /// Ambient, non-distracting — background colour shifts.
    static let gentle  = Animation.easeInOut(duration: 0.4)

    /// Stagger helper — delays the base animation by index * 50ms.
    static func staggered(_ index: Int, base: Animation = .snappy) -> Animation {
        base.delay(Double(index) * 0.05)
    }
}
