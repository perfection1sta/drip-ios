import SwiftUI

struct ExperienceLevelView: View {
    @Environment(OnboardingViewModel.self) private var vm
    @State private var appeared = false

    private let levels: [(DifficultyLevel, String, String)] = [
        (.beginner,     "Just Starting Out",   "Less than 1 year of consistent training"),
        (.intermediate, "Getting Comfortable",  "1–3 years of training under your belt"),
        (.advanced,     "Seasoned Athlete",     "3+ years and pushing serious limits")
    ]

    var accentColor: Color {
        vm.selectedArchetype?.accentColor ?? .energyOrange
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: Spacing.xxl)

            VStack(spacing: Spacing.xs) {
                Text(OnboardingStep.experience.headline)
                    .font(.displaySmall)
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appeared ? 1 : 0)
            .animation(.smooth.delay(0.05), value: appeared)

            Spacer().frame(height: Spacing.xl)

            VStack(spacing: Spacing.sm) {
                ForEach(Array(levels.enumerated()), id: \.element.0.rawValue) { index, item in
                    let (level, title, subtitle) = item
                    let isSelected = vm.selectedExperience == level

                    Button {
                        HapticManager.shared.selection()
                        vm.selectedExperience = level
                    } label: {
                        HStack(spacing: Spacing.md) {
                            ZStack {
                                Circle()
                                    .fill(isSelected ? accentColor.opacity(0.2) : Color.surfaceTertiary)
                                    .frame(width: 44, height: 44)
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(accentColor)
                                }
                            }
                            .animation(.snappy, value: isSelected)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(title)
                                    .font(.titleSmall)
                                    .foregroundStyle(.textPrimary)
                                Text(subtitle)
                                    .font(.bodySmall)
                                    .foregroundStyle(.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(Spacing.md)
                        .background {
                            RoundedRectangle(cornerRadius: Spacing.Radius.lg)
                                .fill(Color.surfaceSecondary)
                                .overlay {
                                    RoundedRectangle(cornerRadius: Spacing.Radius.lg)
                                        .stroke(isSelected ? accentColor.opacity(0.5) : Color.surfaceTertiary, lineWidth: 1)
                                }
                        }
                    }
                    .buttonStyle(.plain)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.smooth.delay(0.1 + Double(index) * 0.07), value: appeared)
                }
            }

            Spacer()

            DripButton("Continue", style: .primary) {
                vm.advance()
            }
            .opacity(appeared ? 1 : 0)
            .animation(.smooth.delay(0.35), value: appeared)

            Spacer().frame(height: Spacing.xl)
        }
        .padding(.horizontal, Spacing.lg)
        .onAppear { appeared = true }
    }
}
