import SwiftUI

struct ExerciseRowView: View {
    let workoutExercise: WorkoutExercise
    let index: Int

    @State private var isExpanded = false

    var body: some View {
        DripCard(padding: Spacing.md) {
            VStack(spacing: 0) {
                // Row header
                Button {
                    HapticManager.shared.light()
                    withAnimation(.snappy) { isExpanded.toggle() }
                } label: {
                    HStack(spacing: Spacing.md) {
                        // Index circle
                        ZStack {
                            Circle()
                                .fill(LinearGradient.energyGradient)
                                .frame(width: 36, height: 36)
                            Text("\(index)")
                                .font(.labelLarge)
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(workoutExercise.exerciseName)
                                .font(.titleSmall)
                                .foregroundStyle(.textPrimary)
                                .lineLimit(1)
                            HStack(spacing: Spacing.xs) {
                                Text("\(workoutExercise.sets) sets × \(workoutExercise.reps) reps")
                                    .font(.bodySmall)
                                    .foregroundStyle(.textSecondary)
                                Text("·")
                                    .foregroundStyle(.textTertiary)
                                Text(workoutExercise.exerciseEquipment)
                                    .font(.bodySmall)
                                    .foregroundStyle(.textTertiary)
                            }
                        }

                        Spacer()

                        // Muscle chips
                        if let muscle = workoutExercise.primaryMuscles.first {
                            DripBadge(text: muscle.displayName, color: muscle.color)
                        }

                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.textTertiary)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .animation(.snappy, value: isExpanded)
                    }
                }
                .buttonStyle(.plain)

                // Expanded detail
                if isExpanded {
                    MuscleGroupChip(muscles: workoutExercise.primaryMuscles)
                        .padding(.top, Spacing.md)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
}
