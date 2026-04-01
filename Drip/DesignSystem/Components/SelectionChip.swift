import SwiftUI

/// Generic toggleable chip for equipment, goals, injury areas, etc.
struct SelectionChip: View {
    let label: String
    let iconName: String?
    let isSelected: Bool
    let accentColor: Color
    let onTap: () -> Void

    init(label: String,
         iconName: String? = nil,
         isSelected: Bool,
         accentColor: Color = .energyOrange,
         onTap: @escaping () -> Void) {
        self.label = label
        self.iconName = iconName
        self.isSelected = isSelected
        self.accentColor = accentColor
        self.onTap = onTap
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.selection()
            onTap()
        }) {
            HStack(spacing: Spacing.xs) {
                if let icon = iconName {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .medium))
                }
                Text(label)
                    .font(.labelLarge)
                    .lineLimit(1)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .foregroundStyle(isSelected ? accentColor : .textSecondary)
            .background {
                Capsule()
                    .fill(isSelected ? accentColor.opacity(0.15) : Color.surfaceSecondary)
                    .overlay {
                        Capsule()
                            .stroke(
                                isSelected ? accentColor.opacity(0.5) : Color.surfaceTertiary,
                                lineWidth: 1
                            )
                    }
            }
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .animation(.snappy, value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
