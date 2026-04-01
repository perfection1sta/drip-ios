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
            UserProfile.self,
            AIConversation.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    // MARK: - Seed

    /// Seeds exercises for the given archetype and creates a default profile.
    /// Called once on fresh install; respects existing data.
    func seedIfNeeded(context: ModelContext) {
        // Seed exercises — always ensure we have some
        let exerciseCount = (try? context.fetchCount(FetchDescriptor<Exercise>())) ?? 0
        if exerciseCount == 0 {
            // Default to gymBro seed until onboarding completes
            ExerciseSeedData.all(for: .gymBro).forEach { context.insert($0) }
        }

        // Create default profile
        let profileCount = (try? context.fetchCount(FetchDescriptor<UserProfile>())) ?? 0
        if profileCount == 0 {
            context.insert(UserProfile())
        }

        try? context.save()
    }

    /// Re-seeds exercises when user selects a new archetype.
    /// Removes existing exercises and inserts the archetype library.
    func reseedForArchetype(_ archetype: UserArchetype, context: ModelContext) {
        // Remove old exercises
        if let existing = try? context.fetch(FetchDescriptor<Exercise>()) {
            existing.forEach { context.delete($0) }
        }
        // Insert new archetype exercises
        ExerciseSeedData.all(for: archetype).forEach { context.insert($0) }
        try? context.save()
    }

    // MARK: - Today's Workout

    func ensureTodayWorkout(context: ModelContext) {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.generatedDate >= today && $0.generatedDate < tomorrow }
        )
        guard (try? context.fetchCount(descriptor)) == 0 else { return }

        // Only generate if onboarding is done
        let profile = (try? context.fetch(FetchDescriptor<UserProfile>()))?.first
        guard profile?.hasCompletedOnboarding == true else { return }

        let exercises = (try? context.fetch(FetchDescriptor<Exercise>())) ?? []
        let workout = WorkoutGeneratorService.shared.generateWOD(
            exercises: exercises,
            profile: profile,
            date: today
        )
        context.insert(workout)
        try? context.save()
    }

    // MARK: - AI Conversation Pruning

    /// Keeps only the most recent `limit` conversations, deletes the rest.
    func pruneAIConversations(context: ModelContext, limit: Int = 50) {
        var descriptor = FetchDescriptor<AIConversation>(
            sortBy: [SortDescriptor(\.updatedDate, order: .reverse)]
        )
        descriptor.fetchOffset = limit
        if let toDelete = try? context.fetch(descriptor) {
            toDelete.forEach { context.delete($0) }
            try? context.save()
        }
    }

    // MARK: - Delete All Data

    func deleteAllData(context: ModelContext) {
        try? context.delete(model: WorkoutSet.self)
        try? context.delete(model: WorkoutSession.self)
        try? context.delete(model: WorkoutExercise.self)
        try? context.delete(model: Workout.self)
        try? context.delete(model: PersonalRecord.self)
        try? context.delete(model: AIConversation.self)
        // Reset profile stats but keep the profile itself
        if let profile = (try? context.fetch(FetchDescriptor<UserProfile>()))?.first {
            profile.totalWorkoutsCompleted = 0
            profile.currentStreakDays = 0
            profile.longestStreakDays = 0
            profile.hasCompletedOnboarding = false
        }
        try? context.save()
    }
}
