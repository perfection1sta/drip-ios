import SwiftUI

// MARK: - Drip Card
// Base glass-morphism card container used throughout the app.

struct DripCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = Spacing.lg
    var cornerRadius: CGFloat = Spacing.Radius.xl
    var glassEffect: Bool = false

    init(padding: CGFloat = Spacing.lg,
         cornerRadius: CGFloat = Spacing.Radius.xl,
         glassEffect: Bool = false,
         @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.glassEffect = glassEffect
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                Group {
                    if glassEffect {
                        Color.surfaceGlass
                            .background(.ultraThinMaterial)
                    } else {
                        Color.surfaceSecondary
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 8)
    }
}
