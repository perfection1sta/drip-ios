import SwiftUI

extension View {
    // MARK: - Conditional modifier
    @ViewBuilder
    func `if`<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition { transform(self) } else { self }
    }

    // MARK: - Reduce motion helper
    func conditionalAnimation<V: Equatable>(_ animation: Animation?,
                                             value: V,
                                             reduceMotion: Bool) -> some View {
        self.animation(reduceMotion ? nil : animation, value: value)
    }

    // MARK: - Card press effect
    func pressEffect(isPressed: Bool) -> some View {
        self.scaleEffect(isPressed ? 0.97 : 1.0)
    }

    // MARK: - Drip section header
    func dripSectionHeader() -> some View {
        self
            .font(.titleSmall)
            .foregroundStyle(.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
