import SwiftUI

struct PreferencesStepView: View {
    @Environment(OnboardingViewModel.self) private var vm
    @State private var appeared = false

    private let durations = [20, 30, 45, 60, 75, 90]
    private let days = [(1, "Su"), (2, "Mo"), (3, "Tu"), (4, "We"), (5, "Th"), (6, "Fr"), (7, "Sa")]

    var accentColor: Color {
        vm.selectedArchetype?.accentColor ?? .energyOrange
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: Spacing.xxl)

                VStack(spacing: Spacing.xs) {
                    Text(OnboardingStep.preferences.headline)
                        .font(.displaySmall)
                        .foregroundStyle(.textPrimary)
                        .multilineTextAlignment(.center)
                    Text("We'll work around your schedule.")
                        .font(.bodyMedium)
                        .foregroundStyle(.textSecondary)
                }
                .opacity(appeared ? 1 : 0)
                .animation(.smooth.delay(0.05), value: appeared)

                Spacer().frame(height: Spacing.xl)

                // Workout duration
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Session length")
                        .font(.titleSmall)
                        .foregroundStyle(.textPrimary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.xs) {
                            ForEach(durations, id: \.self) { mins in
                                let isSelected = vm.preferredDurationMinutes == mins
                                Button {
                                    HapticManager.shared.selection()
                                    vm.preferredDurationMinutes = mins
                                } label: {
                                    Text("\(mins) min")
                                        .font(.labelLarge)
                                        .foregroundStyle(isSelected ? accentColor : .textSecondary)
                                        .padding(.horizontal, Spacing.sm)
                                        .padding(.vertical, Spacing.xs)
                                        .background {
                                            Capsule()
                                                .fill(isSelected ? accentColor.opacity(0.15) : Color.surfaceSecondary)
                                                .overlay { Capsule().stroke(isSelected ? accentColor.opacity(0.5) : Color.surfaceTertiary, lineWidth: 1) }
                                        }
                                }
                                .buttonStyle(.plain)
                                .animation(.snappy, value: isSelected)
                            }
                        }
                    }
                }
                .opacity(appeared ? 1 : 0)
                .animation(.smooth.delay(0.15), value: appeared)

                Spacer().frame(height: Spacing.xl)

                // Weekly frequency
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text("Days per week")
                            .font(.titleSmall)
                            .foregroundStyle(.textPrimary)
                        Spacer()
                        Text("\(vm.preferredFrequencyDays)×")
                            .font(.statSmall)
                            .foregroundStyle(accentColor)
                    }

                    HStack(spacing: Spacing.xxs) {
                        ForEach(1...7, id: \.self) { count in
                            let isSelected = vm.preferredFrequencyDays == count
                            Button {
                                HapticManager.shared.selection()
                                vm.preferredFrequencyDays = count
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(isSelected ? accentColor : Color.surfaceSecondary)
                                    Text("\(count)")
                                        .font(.titleSmall)
                                        .foregroundStyle(isSelected ? .white : .textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                            }
                            .buttonStyle(.plain)
                            .animation(.snappy, value: isSelected)
                        }
                    }
                }
                .opacity(appeared ? 1 : 0)
                .animation(.smooth.delay(0.2), value: appeared)

                Spacer().frame(height: Spacing.xl)

                // Preferred days
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Preferred days")
                        .font(.titleSmall)
                        .foregroundStyle(.textPrimary)

                    HStack(spacing: Spacing.xxs) {
                        ForEach(days, id: \.0) { dayNum, label in
                            let isSelected = vm.preferredWorkoutDays.contains(dayNum)
                            Button {
                                HapticManager.shared.selection()
                                if isSelected {
                                    vm.preferredWorkoutDays.remove(dayNum)
                                } else {
                                    vm.preferredWorkoutDays.insert(dayNum)
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(isSelected ? accentColor : Color.surfaceSecondary)
                                        .overlay { Circle().stroke(Color.surfaceTertiary, lineWidth: isSelected ? 0 : 1) }
                                    Text(label)
                                        .font(.labelSmall)
                                        .foregroundStyle(isSelected ? .white : .textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                            }
                            .buttonStyle(.plain)
                            .animation(.snappy, value: isSelected)
                        }
                    }
                }
                .opacity(appeared ? 1 : 0)
                .animation(.smooth.delay(0.25), value: appeared)

                Spacer().frame(height: Spacing.xxl)

                DripButton("Let's Build Your Plan", style: .primary) {
                    vm.advance()
                }
            .disabled(!vm.canAdvance)
                .opacity(appeared ? 1 : 0)
                .animation(.smooth.delay(0.35), value: appeared)

                Spacer().frame(height: Spacing.xl)
            }
            .padding(.horizontal, Spacing.lg)
        }
        .onAppear { appeared = true }
    }
}
