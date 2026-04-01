import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var context
    @Environment(OnboardingViewModel.self) private var vm

    var body: some View {
        ZStack {
            // Background
            LinearGradient.darkSurface
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar + back button
                if vm.currentStep != .welcome && vm.currentStep != .complete {
                    HStack(spacing: Spacing.md) {
                        Button(action: vm.goBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.textSecondary)
                                .frame(width: 36, height: 36)
                                .background(Color.surfaceSecondary, in: Circle())
                        }
                        OnboardingProgressBar(progress: vm.progress)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.lg)
                }

                // Step content
                Group {
                    switch vm.currentStep {
                    case .welcome:     WelcomeStepView()
                    case .archetype:   ArchetypeSelectionView()
                    case .experience:  ExperienceLevelView()
                    case .equipment:   EquipmentSelectionView()
                    case .goals:       GoalsSelectionView()
                    case .injuries:    InjurySelectionView()
                    case .preferences: PreferencesStepView()
                    case .complete:    OnboardingCompleteView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(vm.currentStep)
            }
        }
    }
}
