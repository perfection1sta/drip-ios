import SwiftUI

struct WorkoutHeaderView: View {
    let workout: Workout

    var body: some View {
        DripCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text(workout.name)
                        .font(.titleLarge)
                        .foregroundStyle(.textPrimary)
                    Spacer()
                    if workout.isCompleted {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.success)
                            .font(.system(size: 24))
                    }
                }

                // Meta chips
                HStack(spacing: Spacing.xs) {
                    DripBadge(text: workout.difficulty.displayName,
                              color: workout.difficulty.color,
                              icon: "flame.fill")
                    DripBadge(text: "\(workout.estimatedDurationMinutes) min",
                              color: .wellnessTeal,
                              icon: "clock")
                    DripBadge(text: "\(workout.sortedExercises.count) exercises",
                              color: .energyOrange,
                              icon: "list.bullet")
                }

                // Muscle group chips
                if !workout.focusMuscles.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.xs) {
                            ForEach(workout.focusMuscles) { muscle in
                                DripBadge(text: muscle.displayName,
                                          color: muscle.color,
                                          icon: muscle.sfSymbol)
                            }
                        }
                    }
                }
            }
        }
    }
}
