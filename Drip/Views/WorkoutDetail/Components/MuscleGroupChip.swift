import SwiftUI

struct MuscleGroupChip: View {
    let muscles: [MuscleGroup]

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(muscles) { muscle in
                HStack(spacing: 4) {
                    Image(systemName: muscle.sfSymbol)
                        .font(.system(size: 11))
                    Text(muscle.displayName)
                        .font(.labelSmall)
                }
                .foregroundStyle(muscle.color)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, 5)
                .background(muscle.color.opacity(0.15))
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
