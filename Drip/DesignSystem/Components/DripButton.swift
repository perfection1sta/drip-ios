import SwiftUI

// MARK: - Drip Button Styles

enum DripButtonStyle {
    case primary    // energyGradient fill
    case secondary  // glass background
    case ghost      // no fill, outline
    case destructive
}

struct DripButton: View {
    let title: String
    let style: DripButtonStyle
    let icon: String?
    let isLoading: Bool
    let action: () -> Void

    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(_ title: String,
         style: DripButtonStyle = .primary,
         icon: String? = nil,
         isLoading: Bool = false,
         action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.icon = icon
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            HStack(spacing: Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(labelColor)
                        .scaleEffect(0.85)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(.titleSmall)
                }
            }
            .foregroundStyle(labelColor)
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.Radius.xl))
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.Radius.xl)
                    .strokeBorder(borderColor, lineWidth: style == .ghost ? 1.5 : 0)
            )
        }
        .scaleEffect(isPressed && !reduceMotion ? 0.96 : 1.0)
        .animation(reduceMotion ? nil : .snappy, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
        .disabled(isLoading)
    }

    private var buttonHeight: CGFloat {
        switch style {
        case .primary:     return 56
        case .secondary:   return 48
        case .ghost, .destructive: return 44
        }
    }

    private var labelColor: Color {
        switch style {
        case .primary:    return .white
        case .secondary:  return .textPrimary
        case .ghost:      return .energyOrange
        case .destructive: return .white
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary:
            LinearGradient.energyGradient
        case .secondary:
            Color.surfaceGlass.background(.ultraThinMaterial)
        case .ghost:
            Color.clear
        case .destructive:
            Color.error
        }
    }

    private var borderColor: Color {
        style == .ghost ? .energyOrange.opacity(0.6) : .clear
    }
}
