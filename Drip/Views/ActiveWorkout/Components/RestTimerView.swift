import SwiftUI

struct RestTimerView: View {
    @Environment(ActiveWorkoutViewModel.self) private var vm
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var timerColor: Color {
        let r = vm.timerVM.remainingSeconds
        if r <= 5  { return .energyRed }
        if r <= 10 { return .energyOrange }
        return .wellnessTeal
    }

    var body: some View {
        ZStack {
            // Blur background
            Color.black.opacity(0.6)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: Spacing.xxl) {
                VStack(spacing: Spacing.sm) {
                    Text("REST")
                        .font(.labelLarge)
                        .foregroundStyle(.textTertiary)
                        .tracking(4)

                    // Animated ring
                    ZStack {
                        ProgressRingView(
                            progress: vm.timerVM.progress,
                            ringWidth: 10,
                            size: 200,
                            foreground: timerColor
                        )

                        // Timer number
                        Text(vm.timerVM.displayTime)
                            .font(.timerDisplay)
                            .foregroundStyle(.textPrimary)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.snappy, value: vm.timerVM.remainingSeconds)
                    }

                    Text("Next: \(vm.currentExercise?.exerciseName ?? "")")
                        .font(.bodyMedium)
                        .foregroundStyle(.textSecondary)
                        .lineLimit(1)
                }

                VStack(spacing: Spacing.sm) {
                    DripButton("Skip Rest", style: .ghost) {
                        HapticManager.shared.light()
                        withAnimation(.snappy) { vm.skipRest() }
                    }
                    .frame(maxWidth: 200)

                    // +15s / -15s adjust
                    HStack(spacing: Spacing.md) {
                        adjustButton(label: "-15s") {
                            vm.timerVM.remainingSeconds = max(0, vm.timerVM.remainingSeconds - 15)
                        }
                        adjustButton(label: "+15s") {
                            vm.timerVM.remainingSeconds += 15
                            vm.timerVM.totalSeconds = max(vm.timerVM.totalSeconds, vm.timerVM.remainingSeconds)
                        }
                    }
                }
            }
            .padding(Spacing.xxl)
        }
    }

    private func adjustButton(label: String, action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.shared.light()
            action()
        } label: {
            Text(label)
                .font(.labelLarge)
                .foregroundStyle(.textSecondary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(Color.surfaceGlass)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
