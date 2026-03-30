import SwiftUI

struct WorkoutCompleteView: View {
    @Environment(ActiveWorkoutViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false

    var body: some View {
        ZStack {
            LinearGradient.darkSurface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    Spacer(minLength: Spacing.xxl)

                    // Hero celebration
                    VStack(spacing: Spacing.md) {
                        Text("💧")
                            .font(.system(size: 80))
                            .scaleEffect(appeared ? 1.0 : 0.3)
                            .animation(.bouncy.delay(0.1), value: appeared)

                        Text("Workout Complete!")
                            .font(.displayMedium)
                            .foregroundStyle(.textPrimary)
                            .opacity(appeared ? 1 : 0)
                            .animation(.smooth.delay(0.3), value: appeared)

                        Text("You absolutely dripped today.")
                            .font(.bodyLarge)
                            .foregroundStyle(.textSecondary)
                            .opacity(appeared ? 1 : 0)
                            .animation(.smooth.delay(0.4), value: appeared)
                    }

                    // Stats summary
                    if let session = vm.session {
                        DripCard {
                            VStack(spacing: Spacing.lg) {
                                Text("Session Summary")
                                    .font(.titleSmall)
                                    .foregroundStyle(.textSecondary)

                                HStack(spacing: Spacing.md) {
                                    summaryItem(label: "Duration",
                                                value: session.durationFormatted,
                                                icon: "clock.fill",
                                                color: .wellnessTeal)
                                    Divider().background(Color.surfaceTertiary)
                                    summaryItem(label: "Volume",
                                                value: "\(Int(session.totalVolumeLbs)) lbs",
                                                icon: "scalemass.fill",
                                                color: .energyOrange)
                                    Divider().background(Color.surfaceTertiary)
                                    summaryItem(label: "Calories",
                                                value: "\(Int(session.caloriesBurned))",
                                                icon: "flame.fill",
                                                color: .energyRed)
                                }

                                ProgressRingView(
                                    progress: session.completionPercentage,
                                    ringWidth: 8,
                                    size: 80,
                                    foreground: .energyOrange,
                                    showPercent: true
                                )
                            }
                        }
                        .opacity(appeared ? 1 : 0)
                        .animation(.smooth.delay(0.5), value: appeared)
                    }

                    DripButton("Done") {
                        HapticManager.shared.success()
                        dismiss()
                    }
                    .opacity(appeared ? 1 : 0)
                    .animation(.smooth.delay(0.7), value: appeared)

                    Spacer(minLength: Spacing.huge)
                }
                .padding(.horizontal, Spacing.md)
            }
        }
        .onAppear {
            HapticManager.shared.success()
            withAnimation { appeared = true }
        }
    }

    private func summaryItem(label: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
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
