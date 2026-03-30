import SwiftUI

struct GoalsSection: View {
    @Environment(SettingsViewModel.self) private var vm
    @Environment(\.modelContext) private var context

    private let goalOptions = [3, 4, 5, 6]

    var body: some View {
        // Weekly goal
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Weekly Workout Goal")
                .foregroundStyle(.textPrimary)

            HStack(spacing: Spacing.sm) {
                ForEach(goalOptions, id: \.self) { days in
                    Button {
                        HapticManager.shared.selection()
                        vm.updateWeeklyGoal(days, context: context)
                    } label: {
                        VStack(spacing: 4) {
                            Text("\(days)")
                                .font(.titleSmall)
                                .foregroundStyle(vm.profile?.weeklyGoalDays == days ? .white : .textPrimary)
                            Text("days")
                                .font(.caption)
                                .foregroundStyle(vm.profile?.weeklyGoalDays == days ? .white.opacity(0.8) : .textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(vm.profile?.weeklyGoalDays == days ? LinearGradient.energyGradient : LinearGradient(colors: [.surfaceTertiary], startPoint: .top, endPoint: .bottom))
                        .clipShape(RoundedRectangle(cornerRadius: Spacing.Radius.md))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))

        // Fitness level
        HStack {
            Text("Fitness Level")
                .foregroundStyle(.textPrimary)
            Spacer()
            Picker("", selection: Binding(
                get: { vm.profile?.fitnessLevel ?? .intermediate },
                set: { vm.updateDifficulty($0, context: context) }
            )) {
                ForEach(DifficultyLevel.allCases) { level in
                    Text(level.displayName).tag(level)
                }
            }
            .pickerStyle(.menu)
            .foregroundStyle(.energyOrange)
        }
    }
}
