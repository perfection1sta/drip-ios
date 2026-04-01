import SwiftUI

/// Full-screen overlay for timed hold exercises (pilates, yoga poses).
/// Shows a countdown ring with the hold duration and completion controls.
struct HoldTimerView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let targetSeconds: Int
    let onComplete: (Int) -> Void  // passes actual seconds held
    let onSkip: () -> Void

    @State private var elapsed: Int = 0
    @State private var isRunning: Bool = false
    @State private var timer: Timer?

    var progress: Double {
        guard targetSeconds > 0 else { return 1 }
        return min(Double(elapsed) / Double(targetSeconds), 1.0)
    }

    var isComplete: Bool { elapsed >= targetSeconds }

    var displayTime: String {
        let remaining = max(targetSeconds - elapsed, 0)
        return String(format: "%d", remaining)
    }

    var ringColor: Color {
        if progress >= 1.0 { return .success }
        if progress >= 0.7 { return .wellnessTeal }
        return .archetypePilates
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            .background(.ultraThinMaterial)

            VStack(spacing: Spacing.xl) {
                Text("HOLD")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .tracking(4)
                    .foregroundStyle(.textSecondary)

                // Ring + countdown
                ZStack {
                    ProgressRingView(progress: progress, ringWidth: 10, size: 200, foreground: ringColor)
                        .animation(reduceMotion ? nil : .smooth, value: progress)

                    VStack(spacing: Spacing.xxs) {
                        Text(displayTime)
                            .font(.timerDisplay)
                            .foregroundStyle(.textPrimary)
                            .contentTransition(.numericText())

                        Text("seconds")
                            .font(.labelSmall)
                            .foregroundStyle(.textSecondary)
                    }
                }

                if isComplete {
                    VStack(spacing: Spacing.sm) {
                        Text("Hold Complete! 🎉")
                            .font(.titleMedium)
                            .foregroundStyle(.success)

                        DripButton("Done", style: .primary) {
                            HapticManager.shared.success()
                            onComplete(elapsed)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    VStack(spacing: Spacing.sm) {
                        if !isRunning {
                            DripButton("Start Hold", style: .primary) {
                                startTimer()
                            }
                        }

                        Button("Log Partial Hold") {
                            stopTimer()
                            onComplete(elapsed)
                        }
                        .font(.bodyMedium)
                        .foregroundStyle(.textSecondary)
                    }
                }
            }
            .padding(Spacing.xl)
        }
        .onDisappear { stopTimer() }
    }

    private func startTimer() {
        isRunning = true
        HapticManager.shared.light()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsed += 1
            if elapsed >= targetSeconds {
                HapticManager.shared.success()
                stopTimer()
            } else if elapsed == targetSeconds - 3 {
                HapticManager.shared.timerPulse(secondsRemaining: 3)
            } else if elapsed == targetSeconds - 10 {
                HapticManager.shared.timerPulse(secondsRemaining: 10)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
}
