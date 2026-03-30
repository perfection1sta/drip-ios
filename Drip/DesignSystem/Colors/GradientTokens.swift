import SwiftUI

// MARK: - Gradient Tokens

extension LinearGradient {
    static let energyGradient = LinearGradient(
        colors: [.energyRed, .energyOrange],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let darkSurface = LinearGradient(
        colors: [Color(red: 0.051, green: 0.051, blue: 0.059),
                 Color(red: 0.102, green: 0.102, blue: 0.176)],
        startPoint: .top, endPoint: .bottom
    )
    static let tealWellness = LinearGradient(
        colors: [.wellnessTeal, Color(red: 0.039, green: 0.545, blue: 0.545)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let goldAchieve = LinearGradient(
        colors: [.achieveGold, Color(red: 1.0, green: 0.584, blue: 0.0)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let successGradient = LinearGradient(
        colors: [.success, Color(red: 0.0, green: 0.627, blue: 0.176)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

extension RadialGradient {
    static func glowEffect(color: Color, radius: CGFloat = 120) -> RadialGradient {
        RadialGradient(
            colors: [color.opacity(0.3), color.opacity(0.0)],
            center: .center,
            startRadius: 0,
            endRadius: radius
        )
    }
}
