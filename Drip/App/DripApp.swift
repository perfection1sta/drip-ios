import SwiftUI
import SwiftData

@main
struct DripApp: App {
    private let swiftDataService = SwiftDataService.shared

    @State private var homeVM          = HomeViewModel()
    @State private var activeWorkoutVM = ActiveWorkoutViewModel()
    @State private var libraryVM       = ExerciseLibraryViewModel()
    @State private var progressVM      = ProgressViewModel()
    @State private var settingsVM      = SettingsViewModel()
    @State private var onboardingVM    = OnboardingViewModel()
    @State private var aiCoachVM       = AICoachViewModel()

    @State private var onboardingComplete = false

    var body: some Scene {
        WindowGroup {
            RootView(onboardingComplete: $onboardingComplete)
                .modelContainer(swiftDataService.container)
                .environment(homeVM)
                .environment(activeWorkoutVM)
                .environment(libraryVM)
                .environment(progressVM)
                .environment(settingsVM)
                .environment(onboardingVM)
                .environment(aiCoachVM)
                .preferredColorScheme(.dark)
                .onAppear {
                    let context = swiftDataService.container.mainContext
                    swiftDataService.seedIfNeeded(context: context)

                    // Check onboarding state
                    let profile = (try? context.fetch(FetchDescriptor<UserProfile>()))?.first
                    onboardingComplete = profile?.hasCompletedOnboarding ?? false

                    if onboardingComplete {
                        swiftDataService.ensureTodayWorkout(context: context)
                        homeVM.load(context: context)
                    }
                }
        }
    }
}

// MARK: - Root routing view
private struct RootView: View {
    @Environment(\.modelContext) private var context
    @Environment(OnboardingViewModel.self) private var onboardingVM
    @Environment(HomeViewModel.self) private var homeVM
    @Binding var onboardingComplete: Bool

    var body: some View {
        Group {
            if onboardingComplete {
                MainTabView()
            } else {
                OnboardingContainerView()
            }
        }
        // Watch for onboarding completion to transition to main app
        .onChange(of: onboardingVM.currentStep) { _, step in
            if step == .complete {
                // Brief delay for celebration animation.
                // Use container.mainContext — @Environment context may be detached after view swap.
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    let ctx = SwiftDataService.shared.container.mainContext
                    SwiftDataService.shared.ensureTodayWorkout(context: ctx)
                    homeVM.load(context: ctx)
                    withAnimation(.smooth) {
                        onboardingComplete = true
                    }
                }
            }
        }
    }
}
