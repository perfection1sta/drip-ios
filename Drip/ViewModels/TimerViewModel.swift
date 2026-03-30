import SwiftUI
import Combine

enum TimerMode { case countUp, countDown }

@Observable
final class TimerViewModel {
    var displayTime: String = "00:00"
    var elapsedSeconds: Int = 0
    var remainingSeconds: Int = 0
    var totalSeconds: Int = 0
    var progress: Double = 0.0
    var isRunning: Bool = false
    var mode: TimerMode = .countUp
    var hasFinished: Bool = false

    private var timer: Timer?
    private var startDate: Date?

    // MARK: - Control

    func startCountUp() {
        mode = .countUp
        elapsedSeconds = 0
        startDate = Date()
        hasFinished = false
        scheduleTimer()
    }

    func startCountDown(duration: Int) {
        mode = .countDown
        totalSeconds = duration
        remainingSeconds = duration
        hasFinished = false
        startDate = Date()
        scheduleTimer()
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func resume() {
        guard !isRunning else { return }
        startDate = Date().addingTimeInterval(
            mode == .countUp ? -Double(elapsedSeconds) : -Double(totalSeconds - remainingSeconds)
        )
        scheduleTimer()
    }

    func reset() {
        pause()
        elapsedSeconds = 0
        remainingSeconds = 0
        progress = 0
        displayTime = "00:00"
        hasFinished = false
    }

    // MARK: - Private

    private func scheduleTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func tick() {
        guard let startDate else { return }
        let elapsed = Int(Date().timeIntervalSince(startDate))

        switch mode {
        case .countUp:
            elapsedSeconds = elapsed
            displayTime = formatTime(elapsed)
            progress = min(Double(elapsed) / 3600.0, 1.0) // normalise to 1hr

        case .countDown:
            let remaining = max(0, totalSeconds - elapsed)
            remainingSeconds = remaining
            displayTime = formatTime(remaining)
            progress = totalSeconds > 0 ? Double(remaining) / Double(totalSeconds) : 0

            HapticManager.shared.timerPulse(secondsRemaining: remaining)

            if remaining == 0 {
                hasFinished = true
                pause()
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
