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
                    HStack(spacing: Spacing.sm) {
                        // Index circle
                        ZStack {
                            Circle()
                                .fill(LinearGradient.energyGradient)
                                .frame(width: 34, height: 34)
                            Text("\(index)")
                                .font(.labelLarge)
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(workoutExercise.exerciseName)
                                .font(.titleSmall)
                                .foregroundStyle(.textPrimary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("\(workoutExercise.sets) sets × \(workoutExercise.reps) reps")
                                .font(.bodySmall)
                                .foregroundStyle(.textSecondary)
                        }

                        Spacer(minLength: Spacing.xs)

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
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Divider()
                            .background(Color.surfaceTertiary)
                            .padding(.top, Spacing.sm)

                        // Muscles
                        if !workoutExercise.primaryMuscles.isEmpty {
                            detailRow(icon: "figure.strengthtraining.traditional", label: "Muscles") {
                                HStack(spacing: Spacing.xxs) {
                                    ForEach(workoutExercise.primaryMuscles) { muscle in
                                        DripBadge(text: muscle.displayName, color: muscle.color)
                                    }
                                }
                            }
                        }

                        // Equipment
                        detailRow(icon: "wrench.and.screwdriver", label: "Equipment") {
                            Text(workoutExercise.exerciseEquipment)
                                .font(.bodySmall)
                                .foregroundStyle(.textSecondary)
                        }

                        // Rest time
                        detailRow(icon: "timer", label: "Rest") {
                            Text("\(workoutExercise.exerciseRestSeconds)s between sets")
                                .font(.bodySmall)
                                .foregroundStyle(.textSecondary)
                        }

                        // Style badge
                        detailRow(icon: "bolt.fill", label: "Style") {
                            Text(workoutExercise.workoutStyle.shortDescription)
                                .font(.bodySmall)
                                .foregroundStyle(.textSecondary)
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }

    @ViewBuilder
    private func detailRow<Content: View>(icon: String, label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(.textTertiary)
                .frame(width: 16)
            Text(label)
                .font(.labelSmall)
                .foregroundStyle(.textTertiary)
                .frame(width: 64, alignment: .leading)
            content()
            Spacer()
        }
    }
}
