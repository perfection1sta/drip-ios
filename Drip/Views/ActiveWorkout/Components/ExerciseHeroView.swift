import SwiftUI

struct ExerciseHeroView: View {
    let workoutExercise: WorkoutExercise
    let exerciseIndex: Int
    let totalExercises: Int

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Icon with glow
            ZStack {
                Circle()
                    .fill(RadialGradient.glowEffect(color: primaryMuscleColor, radius: 80))
                    .frame(width: 160, height: 160)

                Image(systemName: workoutExercise.exerciseIconName)
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(primaryMuscleColor)
                    .symbolRenderingMode(.hierarchical)
            }

            // Exercise name + counter
            VStack(spacing: Spacing.xs) {
                Text("\(exerciseIndex + 1) of \(totalExercises)")
                    .font(.labelSmall)
                    .foregroundStyle(.white.opacity(0.5))

                Text(workoutExercise.exerciseName)
                    .font(.titleLarge)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)

                // Muscle chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.xs) {
                        ForEach(workoutExercise.primaryMuscles) { muscle in
                            DripBadge(text: muscle.displayName,
                                      color: muscle.color,
                                      icon: muscle.sfSymbol)
                        }
                        DripBadge(text: workoutExercise.exerciseEquipment,
                                  color: .textTertiary)
                    }
                }

                Text("Set \(workoutExercise.sets) × \(workoutExercise.reps) reps")
                    .font(.bodyMedium)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .id(workoutExercise.id) // triggers transition on exercise change
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }

    private var primaryMuscleColor: Color {
        workoutExercise.primaryMuscles.first?.color ?? .energyOrange
    }
}
