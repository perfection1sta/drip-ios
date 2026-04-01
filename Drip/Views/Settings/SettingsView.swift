import SwiftUI

struct SettingsView: View {
    @Environment(SettingsViewModel.self) private var vm
    @Environment(OnboardingViewModel.self) private var onboardingVM
    @Environment(\.modelContext) private var context
    @State private var showExportSheet = false
    @State private var exportURL: URL?
    @State private var showArchetypeSheet = false

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

                    // Training style
                    Section("Training Style") {
                        archetypeRow
                        GoalsSection()
                    }
                    .listRowBackground(Color.surfaceSecondary)

                    // Notifications
                    Section("Notifications") {
                        NotificationsSection()
                    }
                    .listRowBackground(Color.surfaceSecondary)

                    // AI Coach (Beta)
                    Section {
                        aiCoachSection
                    } header: {
                        HStack(spacing: Spacing.xs) {
                            Text("AI Coach")
                            BetaBadge()
                        }
                    }
                    .listRowBackground(Color.surfaceSecondary)

                    // Data & Privacy
                    Section("Data & Privacy") {
                        Button {
                            exportURL = vm.exportWorkoutHistory(context: context)
                            showExportSheet = exportURL != nil
                        } label: {
                            Label("Export Workout History", systemImage: "square.and.arrow.up")
                                .foregroundStyle(.textPrimary)
                        }

                        Button {
                            vm.showDeleteConfirm = true
                        } label: {
                            Label("Delete All Data", systemImage: "trash")
                                .foregroundStyle(.error)
                        }
                    }
                    .listRowBackground(Color.surfaceSecondary)

                    // About
                    Section("About") {
                        HStack {
                            Text("Version").foregroundStyle(.textSecondary)
                            Spacer()
                            Text("2.0.0").foregroundStyle(.textTertiary)
                        }
                        Button {
                            vm.redoOnboarding(context: context)
                        } label: {
                            Label("Redo Onboarding", systemImage: "arrow.counterclockwise")
                                .foregroundStyle(.textSecondary)
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
        .sheet(isPresented: $showExportSheet) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
        .confirmationDialog("Delete all workout data?", isPresented: $vm.showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete Everything", role: .destructive) {
                vm.deleteAllData(context: context)
                HapticManager.shared.error()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove all workout history, streaks, and personal records. This cannot be undone.")
        }
        .sheet(isPresented: $showArchetypeSheet) {
            archetypePickerSheet
        }
    }

    // MARK: Archetype Row
    private var archetypeRow: some View {
        Button { showArchetypeSheet = true } label: {
            HStack {
                Label {
                    Text("Training Archetype")
                        .foregroundStyle(.textPrimary)
                } icon: {
                    Image(systemName: vm.profile?.archetype.iconName ?? "dumbbell")
                        .foregroundStyle(vm.profile?.archetype.accentColor ?? .energyOrange)
                }

                Spacer()

                Text(vm.profile?.archetype.displayName ?? "—")
                    .foregroundStyle(.textSecondary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.textTertiary)
            }
        }
    }

    // MARK: AI Coach Section
    private var aiCoachSection: some View {
        VStack(spacing: 0) {
            Toggle(isOn: Binding(
                get: { vm.profile?.aiCoachEnabled ?? false },
                set: { vm.toggleAICoach($0, context: context) }
            )) {
                Label("Enable AI Coach", systemImage: "sparkles")
                    .foregroundStyle(.textPrimary)
            }
            .tint(.energyOrange)

            if vm.profile?.aiCoachEnabled == true {
                Divider().background(Color.surfaceTertiary)

                if vm.hasAPIKey {
                    HStack {
                        Label("API Key", systemImage: "key.fill")
                            .foregroundStyle(.textPrimary)
                        Spacer()
                        Text("Saved ✓")
                            .foregroundStyle(.success)
                            .font(TypographyTokens.labelLarge)
                        Button("Remove") { vm.removeAPIKey() }
                            .foregroundStyle(.error)
                            .font(TypographyTokens.labelLarge)
                    }
                } else {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Enter your Claude API key")
                            .font(TypographyTokens.labelLarge)
                            .foregroundStyle(.textSecondary)

                        HStack {
                            SecureField("sk-ant-...", text: Binding(
                                get: { vm.apiKeyInput },
                                set: { vm.apiKeyInput = $0 }
                            ))
                            .font(TypographyTokens.bodySmall)
                            .foregroundStyle(.textPrimary)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)

                            Button("Save") { vm.saveAPIKey() }
                                .foregroundStyle(.energyOrange)
                                .font(TypographyTokens.labelLarge)
                                .disabled(vm.apiKeyInput.isEmpty)
                        }
                    }
                    .padding(.vertical, Spacing.xs)
                }
            }
        }
    }

    // MARK: Archetype Picker Sheet
    private var archetypePickerSheet: some View {
        NavigationView {
            ZStack {
                LinearGradient.darkSurface.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: Spacing.md) {
                        Text("Changing your archetype resets your exercise library.")
                            .font(TypographyTokens.bodySmall)
                            .foregroundStyle(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        ForEach(UserArchetype.allCases) { archetype in
                            ArchetypeCard(
                                archetype: archetype,
                                isSelected: vm.profile?.archetype == archetype,
                                onTap: {
                                    vm.changeArchetype(archetype, context: context)
                                    showArchetypeSheet = false
                                }
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Change Archetype")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { showArchetypeSheet = false }
                }
            }
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
