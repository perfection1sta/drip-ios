import SwiftUI

struct ExerciseFullDetailView: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false

    var primaryColor: Color { exercise.primaryMuscles.first?.color ?? .energyOrange }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.darkSurface.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        // Hero
                        exerciseHero

                        // Description
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("About")
                                .dripSectionHeader()
                            Text(exercise.exerciseDescription)
                                .font(.bodyMedium)
                                .foregroundStyle(.textSecondary)
                        }

                        // Instructions
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("How To")
                                .dripSectionHeader()
                            ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { i, step in
                                HStack(alignment: .top, spacing: Spacing.md) {
                                    ZStack {
                                        Circle()
                                            .fill(primaryColor.opacity(0.2))
                                            .frame(width: 28, height: 28)
                                        Text("\(i + 1)")
                                            .font(.labelSmall)
                                            .foregroundStyle(primaryColor)
                                    }
                                    Text(step)
                                        .font(.bodyMedium)
                                        .foregroundStyle(.textPrimary)
                                }
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 10)
                                .animation(.staggered(i + 2), value: appeared)
                            }
                        }

                        // Tips
                        if !exercise.tips.isEmpty {
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                Text("Pro Tips")
                                    .dripSectionHeader()
                                ForEach(exercise.tips, id: \.self) { tip in
                                    HStack(alignment: .top, spacing: Spacing.sm) {
                                        Image(systemName: "lightbulb.fill")
                                            .foregroundStyle(.achieveGold)
                                            .font(.system(size: 14))
                                        Text(tip)
                                            .font(.bodySmall)
                                            .foregroundStyle(.textSecondary)
                                    }
                                }
                            }
                        }

                        // Default targets
                        DripCard {
                            HStack {
                                statItem(label: "Sets", value: "\(exercise.defaultSets)")
                                Divider().background(Color.surfaceTertiary)
                                statItem(label: "Reps", value: "\(exercise.defaultReps)")
                                Divider().background(Color.surfaceTertiary)
                                statItem(label: "Rest", value: "\(exercise.restDurationSeconds)s")
                                Divider().background(Color.surfaceTertiary)
                                statItem(label: "Cal/min", value: "\(Int(exercise.caloriesPerMinute))")
                            }
                        }

                        Spacer(minLength: Spacing.huge)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.textSecondary)
                            .font(.system(size: 24))
                    }
                }
            }
        }
        .onAppear { withAnimation { appeared = true } }
    }

    private var exerciseHero: some View {
        DripCard {
            VStack(spacing: Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(RadialGradient.glowEffect(color: primaryColor, radius: 70))
                        .frame(width: 140, height: 140)
                    Image(systemName: exercise.iconName)
                        .font(.system(size: 60, weight: .light))
                        .foregroundStyle(primaryColor)
                        .symbolRenderingMode(.hierarchical)
                }

                Text(exercise.name)
                    .font(.displaySmall)
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.center)

                HStack(spacing: Spacing.xs) {
                    DripBadge(text: exercise.category.displayName,
                              color: exercise.category.color,
                              icon: exercise.category.sfSymbol)
                    DripBadge(text: exercise.difficulty.displayName,
                              color: exercise.difficulty.color,
                              icon: "flame.fill")
                    DripBadge(text: exercise.equipment,
                              color: .textTertiary)
                }

                MuscleGroupChip(muscles: exercise.primaryMuscles + exercise.secondaryMuscles)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.titleSmall)
                .foregroundStyle(.textPrimary)
                .monospacedDigit()
            Text(label)
                .font(.caption)
                .foregroundStyle(.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}
