import SwiftUI

// MARK: - Drip Badge
// Pill-shaped label for muscle groups, categories, and difficulty tags.

struct DripBadge: View {
    let text: String
    let color: Color
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(text)
                .font(.labelSmall)
        }
        .foregroundStyle(color)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xxs + 2)
        .background(color.opacity(0.18))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(color.opacity(0.35), lineWidth: 1)
        )
    }
}
