import SwiftUI

struct NotificationsSection: View {
    @Environment(SettingsViewModel.self) private var vm
    @Environment(\.modelContext) private var context

    var body: some View {
        Toggle(isOn: Binding(
            get: { vm.profile?.notificationsEnabled ?? false },
            set: { vm.toggleNotifications($0, context: context) }
        )) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundStyle(.energyOrange)
                    .frame(width: 24)
                Text("Daily Workout Reminder")
                    .foregroundStyle(.textPrimary)
            }
        }
        .tint(.energyOrange)

        if vm.profile?.notificationsEnabled == true {
            DatePicker("Reminder Time",
                       selection: Binding(
                        get: { vm.notificationTime },
                        set: { vm.notificationTime = $0 }
                       ),
                       displayedComponents: .hourAndMinute)
                .foregroundStyle(.textPrimary)
                .tint(.energyOrange)
                .onChange(of: vm.notificationTime) { _, _ in
                    vm.saveProfile(context: context)
                    Task { await NotificationService.shared.scheduleWorkoutReminder(at: vm.notificationTime) }
                }
        }
    }
}
