import SwiftUI

struct ArchetypeSelectionView: View {
    @Environment(OnboardingViewModel.self) private var vm
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: Spacing.xxl)

            VStack(spacing: Spacing.xs) {
                Text(OnboardingStep.archetype.headline)
                    .font(.displaySmall)
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Choose the style that matches how you like to move.")
                    .font(.bodyMedium)
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)
            .animation(.smooth.delay(0.05), value: appeared)

            Spacer().frame(height: Spacing.xl)

            // Three archetype cards
            VStack(spacing: Spacing.md) {
                ForEach(Array(UserArchetype.allCases.enumerated()), id: \.element.id) { index, archetype in
                    ArchetypeCard(
                        archetype: archetype,
                        isSelected: vm.selectedArchetype == archetype,
                        onTap: { vm.selectedArchetype = archetype }
                    )
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 24)
                    .animation(.smooth.delay(0.1 + Double(index) * 0.08), value: appeared)
                }
            }

            Spacer()

            DripButton("Continue", style: .primary) {
                vm.advance()
            }
            .disabled(!vm.canAdvance)
            .opacity(appeared ? 1 : 0)
            .animation(.smooth.delay(0.4), value: appeared)

            Spacer().frame(height: Spacing.xl)
        }
        .padding(.horizontal, Spacing.lg)
        .onAppear { appeared = true }
    }
}
