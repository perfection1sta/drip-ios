import SwiftUI

// MARK: - Stat Pill
// Three-line stat display: label / large number / unit

struct StatPill: View {
    let label: String
    let value: String
    let unit: String
    var accentColor: Color = .energyOrange

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.labelSmall)
                .foregroundStyle(.textTertiary)

            Text(value)
                .font(.statSmall)
                .foregroundStyle(accentColor)
                .monospacedDigit()

            Text(unit)
                .font(.caption)
                .foregroundStyle(.textSecondary)
        }
        .frame(minWidth: 80)
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.surfaceGlass.background(.ultraThinMaterial))
        .clipShape(RoundedRectangle(cornerRadius: Spacing.Radius.lg))
    }
}
