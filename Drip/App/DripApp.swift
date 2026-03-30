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

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(swiftDataService.container)
                .environment(homeVM)
                .environment(activeWorkoutVM)
                .environment(libraryVM)
                .environment(progressVM)
                .environment(settingsVM)
                .preferredColorScheme(.dark)
                .onAppear {
                    let context = swiftDataService.container.mainContext
                    swiftDataService.seedIfNeeded(context: context)
                    swiftDataService.ensureTodayWorkout(context: context)
                    homeVM.load(context: context)
                }
        }
    }
}
