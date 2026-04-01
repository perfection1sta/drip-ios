import SwiftUI

/// Full-screen set-duration timer — counts up with escalating haptics.
/// Shown when user taps "Start Set", dismissed when they tap "Done".
struct SetTimerView: View {
    @Environment(ActiveWorkoutViewModel.self) private var vm
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Count-up state
    @State private var elapsed: Int = 0
    @State private var timer: Timer?
    @State private var ringPulse: Bool = false

    private let accentColor: Color
    private let exerciseName: String
    private let targetReps: Int
    private let setNumber: Int

    init(exercise: WorkoutExercise, setNumber: Int) {
        self.accentColor = exercise.primaryMuscles.first?.color ?? .energyOrange
        self.exerciseName = exercise.exerciseName
        self.targetReps = exercise.reps
        self.setNumber = setNumber
    }

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            accentColor.opacity(0.08).ignoresSafeArea()
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: ringPulse)

            VStack(spacing: 0) {
                Spacer()

                // Label
                VStack(spacing: Spacing.xs) {
                    Text("SET \(setNumber)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .tracking(5)
                        .foregroundStyle(accentColor.opacity(0.7))

                    Text(exerciseName)
                        .font(.titleMedium)
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                }

                Spacer().frame(height: Spacing.xxl)

                // Ring + elapsed
                ZStack {
                    // Outer glow ring (decorative, full circle)
                    Circle()
                        .stroke(accentColor.opacity(ringPulse ? 0.15 : 0.06), lineWidth: 24)
                        .frame(width: 260, height: 260)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: ringPulse)

                    // Progress ring — cycles every 60s
                    ProgressRingView(
                        progress: Double(elapsed % 60) / 60.0,
                        ringWidth: 6,
                        size: 260,
                        foreground: accentColor
                    )

                    // Time
                    VStack(spacing: Spacing.xs) {
                        Text(formattedTime)
                            .font(.system(size: 80, weight: .thin).monospacedDigit())
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                            .animation(.snappy, value: elapsed)

                        Text("\(targetReps) reps")
                            .font(.labelLarge)
                            .foregroundStyle(.white.opacity(0.35))
                    }
                }

                Spacer().frame(height: Spacing.xxxl)

                // Done button
                Button {
                    stopTimer()
                    HapticManager.shared.medium()
                    withAnimation(.snappy) { vm.showSetTimer = false }
                } label: {
                    ZStack {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 80, height: 80)
                            .shadow(color: accentColor.opacity(0.5), radius: 20, y: 6)
                        Image(systemName: "checkmark")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(ScaleDownButtonStyle())

                Spacer().frame(height: Spacing.sm)

                Text("Done")
                    .font(.labelSmall)
                    .foregroundStyle(.white.opacity(0.3))

                Spacer()
            }
        }
        .onAppear {
            elapsed = 0
            ringPulse = true
            startTimer()
            HapticManager.shared.medium()
        }
        .onDisappear { stopTimer() }
    }

    // MARK: Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsed += 1
            fireHaptic(at: elapsed)
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func fireHaptic(at seconds: Int) {
        switch seconds {
        case 10, 20, 30:
            HapticManager.shared.light()
        case 45:
            HapticManager.shared.medium()
        case 60:
            HapticManager.shared.heavy()
            // Every 30s after 60
        case _ where seconds > 60 && seconds % 30 == 0:
            HapticManager.shared.heavy()
        default:
            break
        }
    }

    private var formattedTime: String {
        let m = elapsed / 60
        let s = elapsed % 60
        if m > 0 {
            return String(format: "%d:%02d", m, s)
        }
        return String(format: "%02d", s)
    }
}

private struct ScaleDownButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.snappy, value: configuration.isPressed)
    }
}
