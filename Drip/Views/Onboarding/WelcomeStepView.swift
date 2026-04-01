import SwiftUI

struct WelcomeStepView: View {
    @Environment(OnboardingViewModel.self) private var vm
    @Bindable private var bindableVM: OnboardingViewModel
    @FocusState private var nameFocused: Bool
    @State private var appeared = false

    init() {
        // Workaround: @Environment doesn't support @Bindable directly in init
        self.bindableVM = OnboardingViewModel()
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo / Icon
            ZStack {
                Circle()
                    .fill(LinearGradient.energyGradient)
                    .frame(width: 100, height: 100)
                    .shadow(color: .energyOrange.opacity(0.4), radius: 24, y: 8)
                Text("💧")
                    .font(.system(size: 48))
            }
            .scaleEffect(appeared ? 1 : 0.4)
            .opacity(appeared ? 1 : 0)
            .animation(.bouncy.delay(0.1), value: appeared)

            Spacer().frame(height: Spacing.xxl)

            VStack(spacing: Spacing.sm) {
                Text("Welcome to Drip")
                    .font(TypographyTokens.displaySmall)
                    .foregroundStyle(.textPrimary)

                Text("Your personal fitness coach.\nLet's get to know you.")
                    .font(TypographyTokens.bodyLarge)
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.smooth.delay(0.2), value: appeared)

            Spacer().frame(height: Spacing.xxl)

            // Name input
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("What should we call you?")
                    .font(TypographyTokens.labelLarge)
                    .foregroundStyle(.textSecondary)
                    .padding(.leading, Spacing.xs)

                TextField("Your name", text: Binding(
                    get: { vm.name },
                    set: { vm.name = $0 }
                ))
                .font(TypographyTokens.titleMedium)
                .foregroundStyle(.textPrimary)
                .padding(Spacing.md)
                .background(Color.surfaceSecondary, in: RoundedRectangle(cornerRadius: Spacing.Radius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: Spacing.Radius.lg)
                        .stroke(nameFocused ? Color.energyOrange.opacity(0.6) : Color.surfaceTertiary, lineWidth: 1)
                )
                .focused($nameFocused)
                .submitLabel(.continue)
                .onSubmit { if vm.canAdvance { vm.advance() } }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.smooth.delay(0.3), value: appeared)

            Spacer().frame(height: Spacing.xxl)

            DripButton("Let's Go", style: .primary, isDisabled: !vm.canAdvance) {
                vm.advance()
            }
            .opacity(appeared ? 1 : 0)
            .animation(.smooth.delay(0.4), value: appeared)

            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .onAppear {
            appeared = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                nameFocused = true
            }
        }
    }
}
