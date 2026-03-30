import SwiftData
import Foundation

// MARK: - SwiftData Service
// Sets up the ModelContainer and seeds initial data on first launch.

final class SwiftDataService {
    static let shared = SwiftDataService()
    private init() {}

    lazy var container: ModelContainer = {
        let schema = Schema([
            Exercise.self,
            Workout.self,
            WorkoutExercise.self,
            WorkoutSession.self,
            WorkoutSet.self,
            PersonalRecord.self,
            UserProfile.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    func seedIfNeeded(context: ModelContext) {
        // Seed exercises
        let exerciseCount = (try? context.fetchCount(FetchDescriptor<Exercise>())) ?? 0
        if exerciseCount == 0 {
            ExerciseSeedData.all().forEach { context.insert($0) }
        }

        // Create default profile
        let profileCount = (try? context.fetchCount(FetchDescriptor<UserProfile>())) ?? 0
        if profileCount == 0 {
            context.insert(UserProfile())
        }

        try? context.save()
    }

    // MARK: - Convenience: Generate today's workout if not already done
    func ensureTodayWorkout(context: ModelContext) {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.generatedDate >= today && $0.generatedDate < tomorrow }
        )
        guard (try? context.fetchCount(descriptor)) == 0 else { return }

        let exercises = (try? context.fetch(FetchDescriptor<Exercise>())) ?? []
        let profile = (try? context.fetch(FetchDescriptor<UserProfile>()))?.first

        let workout = WorkoutGeneratorService.shared.generateWOD(
            exercises: exercises,
            profile: profile,
            date: today
        )
        context.insert(workout)
        try? context.save()
    }
}
