import UIKit

// MARK: - Haptic Manager
// Centralised haptic feedback — use these instead of raw UIKit generators
// so every action has consistent physical feel across the app.

final class HapticManager {
    static let shared = HapticManager()
    private init() {}

    // MARK: Impact
    func light()  { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    func medium() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    func heavy()  { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
    func rigid()  { UIImpactFeedbackGenerator(style: .rigid).impactOccurred() }

    // MARK: Notification
    func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    func error()   { UINotificationFeedbackGenerator().notificationOccurred(.error) }

    // MARK: Selection
    func selection() { UISelectionFeedbackGenerator().selectionChanged() }

    // MARK: Compound patterns

    /// Three ascending impacts — fired on a new Personal Record.
    func personalRecord() {
        medium()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { self.heavy() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) { self.rigid() }
    }

    /// Countdown pulse — called at each remaining second of the rest timer.
    func timerPulse(secondsRemaining: Int) {
        switch secondsRemaining {
        case 5...: light()
        case 3:    medium()
        case 1, 2: heavy()
        case 0:    success()
        default:   break
        }
    }

    /// Set completed — medium + double light tap.
    func setComplete() {
        medium()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) { self.light() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) { self.light() }
    }
}
