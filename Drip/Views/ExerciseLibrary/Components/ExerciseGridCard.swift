import SwiftUI

struct ExerciseGridCard: View {
    let exercise: Exercise
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            DripCard(padding: Spacing.md, cornerRadius: Spacing.Radius.xl) {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    // Icon with colored background
                    ZStack {
                        RoundedRectangle(cornerRadius: Spacing.Radius.md)
                            .fill(primaryColor.opacity(0.15))
                            .frame(height: 56)
                        Image(systemName: exercise.iconName)
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(primaryColor)
                            .symbolRenderingMode(.hierarchical)
                    }

                    Text(exercise.name)
                        .font(.labelLarge)
                        .foregroundStyle(.textPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        DripBadge(text: exercise.primaryMuscles.first?.displayName ?? "",
                                  color: primaryColor)
                        Spacer()
                        HStack(spacing: 2) {
                            ForEach(0..<3) { i in
                                Image(systemName: i < exercise.difficulty.stars ? "star.fill" : "star")
                                    .font(.system(size: 9))
                                    .foregroundStyle(exercise.difficulty.color)
                            }
                        }
                    }
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var primaryColor: Color {
        exercise.primaryMuscles.first?.color ?? .energyOrange
    }
}

// Lightweight press-to-scale button style that doesn't interfere with ScrollView
private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.snappy, value: configuration.isPressed)
    }
}
