import SwiftUI

/// Shown at the top of the active workout view for circuit/AMRAP/EMOM workouts.
/// Displays current round and progress through the circuit.
struct CircuitRoundView: View {
    let currentRound: Int
    let totalRounds: Int
    let currentExerciseIndex: Int
    let totalExercises: Int
    let workoutStyle: WorkoutStyle
    let accentColor: Color

    var roundProgress: Double {
        guard totalRounds > 0 else { return 0 }
        return Double(currentRound - 1) / Double(totalRounds)
    }

    var body: some View {
        VStack(spacing: Spacing.xs) {
            HStack {
                // Style badge
                Text(workoutStyle.displayName.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(accentColor)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, 2)
                    .background(accentColor.opacity(0.15), in: Capsule())

                Spacer()

                // Round indicator
                Text(workoutStyle == .amrap ? "AMRAP" : "Round \(currentRound) / \(totalRounds)")
                    .font(TypographyTokens.labelLarge)
                    .foregroundStyle(.textSecondary)
            }

            // Exercise dots
            HStack(spacing: Spacing.xs) {
                ForEach(0..<totalExercises, id: \.self) { index in
                    Capsule()
                        .fill(index < currentExerciseIndex ? accentColor :
                              index == currentExerciseIndex ? accentColor.opacity(0.8) : Color.surfaceTertiary)
                        .frame(height: 4)
                        .scaleEffect(x: 1, y: index == currentExerciseIndex ? 1.5 : 1)
                        .animation(.snappy, value: currentExerciseIndex)
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(.ultraThinMaterial)
    }
}
