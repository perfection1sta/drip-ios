import SwiftUI

struct GoalsSelectionView: View {
    @Environment(OnboardingViewModel.self) private var vm
    @State private var appeared = false

    var accentColor: Color {
        vm.selectedArchetype?.accentColor ?? .energyOrange
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: Spacing.xxl)

            VStack(spacing: Spacing.xs) {
                Text(OnboardingStep.goals.headline)
                    .font(.displaySmall)
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.center)
                Text("Pick as many as apply.")
                    .font(.bodyMedium)
                    .foregroundStyle(.textSecondary)
            }
            .opacity(appeared ? 1 : 0)
            .animation(.smooth.delay(0.05), value: appeared)

            Spacer().frame(height: Spacing.xl)

            ScrollView {
                VStack(spacing: Spacing.sm) {
                    ForEach(Array(vm.relevantGoals.enumerated()), id: \.element.id) { index, goal in
                        let isSelected = vm.selectedGoals.contains(goal)

                        Button {
                            HapticManager.shared.selection()
                            if isSelected {
                                vm.selectedGoals.remove(goal)
                            } else {
                                vm.selectedGoals.insert(goal)
                            }
                        } label: {
                            HStack(spacing: Spacing.md) {
                                Image(systemName: goal.iconName)
                                    .font(.system(size: 20))
                                    .foregroundStyle(isSelected ? accentColor : .textSecondary)
                                    .frame(width: 28)

                                Text(goal.displayName)
                                    .font(.titleSmall)
                                    .foregroundStyle(.textPrimary)

                                Spacer()

                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(accentColor)
                                        .transition(.scale.combined(with: .opacity))
                                }
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
                        .animation(.snappy, value: isSelected)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.smooth.delay(0.1 + Double(index) * 0.05), value: appeared)
                    }
                }
                .padding(.bottom, Spacing.xl)
            }

            DripButton("Continue", style: .primary) {
                vm.advance()
            }
            .disabled(!vm.canAdvance)

            Spacer().frame(height: Spacing.xl)
        }
        .padding(.horizontal, Spacing.lg)
        .onAppear { appeared = true }
    }
}
