import SwiftUI

struct AIWorkoutSuggestionCard: View {
    let plan: WorkoutPlan
    let onStart: () -> Void
    let onDismiss: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundStyle(.achieveGold)
                    Text("AI WORKOUT")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(.achieveGold)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.textSecondary)
                }
            }

            // Workout details
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(plan.name)
                    .font(TypographyTokens.titleMedium)
                    .foregroundStyle(.textPrimary)

                HStack(spacing: Spacing.md) {
                    Label("\(plan.estimatedMinutes) min", systemImage: "clock")
                    Label("\(plan.exercises.count) exercises", systemImage: "list.bullet")
                    if let rounds = plan.rounds, rounds > 1 {
                        Label("\(rounds) rounds", systemImage: "arrow.circlepath")
                    }
                }
                .font(TypographyTokens.labelLarge)
                .foregroundStyle(.textSecondary)
            }

            // Exercise preview
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                ForEach(plan.exercises.prefix(4), id: \.name) { ex in
                    HStack(spacing: Spacing.xs) {
                        Circle()
                            .fill(Color.energyOrange.opacity(0.5))
                            .frame(width: 5, height: 5)
                        Text(ex.name)
                            .font(TypographyTokens.bodySmall)
                            .foregroundStyle(.textSecondary)
                        Spacer()
                        if let reps = ex.reps {
                            Text("\(ex.sets)×\(reps)")
                                .font(TypographyTokens.labelSmall)
                                .foregroundStyle(.textTertiary)
                        } else if let hold = ex.holdSeconds {
                            Text("\(hold)s hold")
                                .font(TypographyTokens.labelSmall)
                                .foregroundStyle(.textTertiary)
                        }
                    }
                }
                if plan.exercises.count > 4 {
                    Text("+\(plan.exercises.count - 4) more")
                        .font(TypographyTokens.caption)
                        .foregroundStyle(.textTertiary)
                }
            }

            // CTA
            DripButton("Start This Workout", style: .primary, icon: "play.fill") {
                HapticManager.shared.success()
                onStart()
            }
        }
        .padding(Spacing.lg)
        .background {
            RoundedRectangle(cornerRadius: Spacing.Radius.xl)
                .fill(Color.surfaceSecondary)
                .overlay {
                    RoundedRectangle(cornerRadius: Spacing.Radius.xl)
                        .stroke(Color.achieveGold.opacity(0.35), lineWidth: 1)
                }
                .shadow(color: .achieveGold.opacity(0.15), radius: 16, y: 4)
        }
        .padding(.horizontal, Spacing.md)
        .scaleEffect(appeared ? 1 : 0.92)
        .opacity(appeared ? 1 : 0)
        .animation(.bouncy.delay(0.1), value: appeared)
        .onAppear { appeared = true }
    }
}
