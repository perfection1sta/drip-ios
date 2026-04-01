import SwiftUI

struct ArchetypeCard: View {
    let archetype: UserArchetype
    let isSelected: Bool
    let onTap: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: {
            HapticManager.shared.selection()
            onTap()
        }) {
            VStack(spacing: Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(archetype.accentColor.opacity(isSelected ? 0.25 : 0.10))
                        .frame(width: 64, height: 64)
                    Image(systemName: archetype.iconName)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(archetype.accentColor)
                }

                // Text
                VStack(spacing: Spacing.xxs) {
                    Text(archetype.displayName)
                        .font(.titleSmall)
                        .foregroundStyle(.textPrimary)

                    Text(archetype.tagline)
                        .font(.bodySmall)
                        .foregroundStyle(.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: Spacing.Radius.xl)
                    .fill(Color.surfaceSecondary)
                    .overlay {
                        RoundedRectangle(cornerRadius: Spacing.Radius.xl)
                            .stroke(
                                isSelected ? archetype.accentColor : Color.surfaceTertiary,
                                lineWidth: isSelected ? 2 : 1
                            )
                    }
            }
            .scaleEffect(pressed ? 0.96 : 1.0)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.snappy, value: isSelected)
            .animation(.snappy, value: pressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }
}
