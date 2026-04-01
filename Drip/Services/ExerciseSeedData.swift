import Foundation

// MARK: - Exercise Seed Data Coordinator
// Routes to the appropriate archetype seed library.
// Each archetype gets ~35-40 curated exercises plus shared basics.

enum ExerciseSeedData {

    /// Returns the exercise library for the given archetype.
    /// Used by SwiftDataService.seedIfNeeded() and reseedForArchetype().
    static func all(for archetype: UserArchetype = .gymBro) -> [Exercise] {
        let shared = SharedSeedData.exercises()
        switch archetype {
        case .gymBro:
            return GymBroSeedData.exercises() + shared
        case .functionalFitness:
            return FunctionalFitnessSeedData.exercises() + shared
        case .pilatesYoga:
            return PilatesYogaSeedData.exercises() + shared
        }
    }
}
