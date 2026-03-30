import SwiftUI

struct SettingsView: View {
    @Environment(SettingsViewModel.self) private var vm
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.darkSurface.ignoresSafeArea()

                List {
                    // Profile header
                    Section {
                        ProfileHeaderView(profile: vm.profile)
                    }
                    .listRowBackground(Color.surfaceSecondary)

                    // Goals
                    Section("Training Goals") {
                        GoalsSection()
                    }
                    .listRowBackground(Color.surfaceSecondary)

                    // Notifications
                    Section("Notifications") {
                        NotificationsSection()
                    }
                    .listRowBackground(Color.surfaceSecondary)

                    // App info
                    Section("About") {
                        HStack {
                            Text("Version")
                                .foregroundStyle(.textSecondary)
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(.textTertiary)
                        }
                        HStack {
                            Text("Drip")
                                .foregroundStyle(.textSecondary)
                            Spacer()
                            Text("💧 Built with SwiftUI")
                                .foregroundStyle(.textTertiary)
                        }
                    }
                    .listRowBackground(Color.surfaceSecondary)
                }
                .scrollContentBackground(.hidden)
                .foregroundStyle(.textPrimary)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear { vm.load(context: context) }
    }
}
