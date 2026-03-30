import UserNotifications
import Foundation

// MARK: - Notification Service

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    private let center = UNUserNotificationCenter.current()

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    // MARK: - Scheduling

    func scheduleWorkoutReminder(at time: Date) async {
        await cancelAll()

        let granted = await requestPermission()
        guard granted else { return }

        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)

        let content = UNMutableNotificationContent()
        content.title = "Time to Drip 💧"
        content.body = "Your workout of the day is ready. Let's get it."
        content.sound = .default
        content.badge = 1

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(
            identifier: "drip.daily.reminder",
            content: content,
            trigger: trigger
        )

        try? await center.add(request)

        // Streak warning — 9 PM if no workout completed today
        await scheduleStreakWarning()
    }

    private func scheduleStreakWarning() async {
        var comps = DateComponents()
        comps.hour = 21
        comps.minute = 0

        let content = UNMutableNotificationContent()
        content.title = "Don't break the streak! 🔥"
        content.body = "You haven't worked out yet today. Your streak is on the line."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(
            identifier: "drip.streak.warning",
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }

    func cancelAll() async {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}
