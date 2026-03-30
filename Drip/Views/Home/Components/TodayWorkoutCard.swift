import SwiftUI

struct TodayWorkoutCard: View {
    let workout: Workout
    let namespace: Namespace.ID
    let onStart: () -> Void

    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: onStart) {
            ZStack(alignment: .bottomLeading) {
                // Background gradient
                LinearGradient.energyGradient
                    .clipShape(RoundedRectangle(cornerRadius: Spacing.Radius.xxl))

                // Decorative icon
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 120, weight: .light))
                    .foregroundStyle(.white.opacity(0.1))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, Spacing.sm)
                    .padding(.trailing, -Spacing.md)

                // Content
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    // Tags row
                    HStack(spacing: Spacing.xs) {
                        DripBadge(text: workout.difficulty.displayName,
                                  color: .white,
                                  icon: "star.fill")
                        DripBadge(text: "\(workout.estimatedDurationMinutes) min",
                                  color: .white,
                                  icon: "clock.fill")
                        if !workout.focusMuscles.isEmpty {
                            DripBadge(text: workout.focusMuscles.first?.displayName ?? "",
                                      color: .white)
                        }
                    }

                    Text(workout.name)
                        .font(.displaySmall)
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    Text("\(workout.sortedExercises.count) exercises")
                        .font(.bodyMedium)
                        .foregroundStyle(.white.opacity(0.8))

                    // Start button
                    HStack {
                        Spacer()
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: workout.isCompleted ? "checkmark.circle.fill" : "play.fill")
                            Text(workout.isCompleted ? "Completed" : "Start Workout")
                                .font(.titleSmall)
                        }
                        .foregroundStyle(workout.isCompleted ? .success : .energyOrange)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(.white)
                        .clipShape(Capsule())
                    }
                }
                .padding(Spacing.xl)
            }
        }
        .buttonStyle(.plain)
        .frame(height: 220)
        .scaleEffect(isPressed && !reduceMotion ? 0.97 : 1.0)
        .animation(reduceMotion ? nil : .snappy, value: isPressed)
        .shadow(color: .energyRed.opacity(0.4), radius: 24, x: 0, y: 8)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
    }
}

struct GeneratingWorkoutCard: View {
    @State private var shimmer = false

    var body: some View {
        RoundedRectangle(cornerRadius: Spacing.Radius.xxl)
            .fill(Color.surfaceSecondary)
            .frame(height: 220)
            .overlay(
                VStack(spacing: Spacing.sm) {
                    ProgressView()
                        .tint(.energyOrange)
                    Text("Generating today's workout…")
                        .font(.bodyMedium)
                        .foregroundStyle(.textSecondary)
                }
            )
    }
}
