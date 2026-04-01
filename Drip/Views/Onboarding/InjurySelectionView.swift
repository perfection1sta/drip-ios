import SwiftUI

struct InjurySelectionView: View {
    @Environment(OnboardingViewModel.self) private var vm
    @State private var appeared = false
    @FocusState private var notesFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: Spacing.xxl)

                VStack(spacing: Spacing.xs) {
                    Text(OnboardingStep.injuries.headline)
                        .font(TypographyTokens.displaySmall)
                        .foregroundStyle(.textPrimary)
                        .multilineTextAlignment(.center)
                    Text("Optional — your AI Coach uses this to keep workouts safe.")
                        .font(TypographyTokens.bodyMedium)
                        .foregroundStyle(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(appeared ? 1 : 0)
                .animation(.smooth.delay(0.05), value: appeared)

                Spacer().frame(height: Spacing.xl)

                // Injury areas grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                    ForEach(Array(InjuryArea.allCases.enumerated()), id: \.element.id) { index, area in
                        let isSelected = vm.selectedInjuries.contains(area)
                        Button {
                            HapticManager.shared.selection()
                            if isSelected {
                                vm.selectedInjuries.remove(area)
                            } else {
                                vm.selectedInjuries.insert(area)
                            }
                        } label: {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: area.iconName)
                                    .font(.system(size: 14))
                                    .foregroundStyle(isSelected ? .error : .textSecondary)
                                Text(area.displayName)
                                    .font(TypographyTokens.labelLarge)
                                    .foregroundStyle(.textPrimary)
                                Spacer()
                            }
                            .padding(Spacing.sm)
                            .background {
                                RoundedRectangle(cornerRadius: Spacing.Radius.md)
                                    .fill(Color.surfaceSecondary)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: Spacing.Radius.md)
                                            .stroke(isSelected ? Color.error.opacity(0.5) : Color.surfaceTertiary, lineWidth: 1)
                                    }
                            }
                        }
                        .buttonStyle(.plain)
                        .animation(.snappy, value: isSelected)
                        .opacity(appeared ? 1 : 0)
                        .animation(.smooth.delay(0.1 + Double(index) * 0.04), value: appeared)
                    }
                }

                // Notes field (shows when any injury selected)
                if !vm.selectedInjuries.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Any details? (e.g. diagnosed condition, cleared by PT)")
                            .font(TypographyTokens.labelLarge)
                            .foregroundStyle(.textSecondary)

                        TextField("Optional notes...", text: Binding(
                            get: { vm.injuryNotes },
                            set: { vm.injuryNotes = $0 }
                        ), axis: .vertical)
                        .font(TypographyTokens.bodyMedium)
                        .foregroundStyle(.textPrimary)
                        .lineLimit(3...5)
                        .padding(Spacing.sm)
                        .background(Color.surfaceSecondary, in: RoundedRectangle(cornerRadius: Spacing.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: Spacing.Radius.md)
                                .stroke(notesFocused ? Color.energyOrange.opacity(0.5) : Color.surfaceTertiary, lineWidth: 1)
                        )
                        .focused($notesFocused)
                    }
                    .padding(.top, Spacing.md)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer().frame(height: Spacing.xxl)

                VStack(spacing: Spacing.sm) {
                    DripButton("Continue", style: .primary) {
                        vm.advance()
                    }
                    Button("No injuries, skip") {
                        vm.selectedInjuries.removeAll()
                        vm.advance()
                    }
                    .font(TypographyTokens.bodyMedium)
                    .foregroundStyle(.textSecondary)
                }
                .opacity(appeared ? 1 : 0)
                .animation(.smooth.delay(0.4), value: appeared)

                Spacer().frame(height: Spacing.xl)
            }
            .padding(.horizontal, Spacing.lg)
        }
        .onAppear { appeared = true }
    }
}
