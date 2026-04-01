import Foundation

// MARK: - Shared Exercise Library
// Universal exercises relevant to all three archetypes.
// Always seeded regardless of archetype selection.

enum SharedSeedData {
    static func exercises() -> [Exercise] { [
        Exercise(name: "Push-Up (Standard)",
                 description: "Universal bodyweight exercise. The foundation of upper body training.",
                 instructions: ["High plank, hands shoulder-width", "Lower chest to floor", "Press back up"],
                 tips: ["Scale on knees if needed"],
                 primaryMuscles: [.chest], secondaryMuscles: [.triceps, .core],
                 category: .strength, difficulty: .beginner,
                 equipment: "Bodyweight", defaultSets: 3, defaultReps: 12,
                 iconName: "figure.strengthtraining.traditional", caloriesPerMinute: 5.5,
                 archetype: .gymBro, workoutStyle: .setsAndReps),

        Exercise(name: "Squat (Bodyweight)",
                 description: "Foundational squat pattern. Can be done anywhere.",
                 instructions: ["Feet shoulder-width, toes slightly out", "Squat to parallel or below", "Drive up through heels"],
                 tips: ["Chest up, knees over toes"],
                 primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes],
                 category: .strength, difficulty: .beginner,
                 equipment: "Bodyweight", defaultSets: 3, defaultReps: 15,
                 iconName: "figure.strengthtraining.functional", caloriesPerMinute: 6.0,
                 archetype: .gymBro, workoutStyle: .setsAndReps),

        Exercise(name: "Plank (Standard)",
                 description: "Core stability hold. Universal for all fitness levels.",
                 instructions: ["Forearms on floor, body straight", "Hold without letting hips sag"],
                 tips: ["Squeeze glutes throughout"],
                 primaryMuscles: [.core], secondaryMuscles: [.shoulders],
                 category: .strength, difficulty: .beginner,
                 equipment: "Bodyweight",
                 defaultDurationSeconds: 45, defaultHoldSeconds: 45,
                 iconName: "figure.strengthtraining.traditional", caloriesPerMinute: 4.0,
                 archetype: .gymBro, workoutStyle: .timedHold),

        Exercise(name: "Walking Lunge",
                 description: "Dynamic leg exercise everyone can do.",
                 instructions: ["Step forward into lunge", "Lower back knee toward floor", "Drive forward with front leg"],
                 tips: ["Keep torso upright"],
                 primaryMuscles: [.quadriceps], secondaryMuscles: [.glutes, .hamstrings],
                 category: .strength, difficulty: .beginner,
                 equipment: "Bodyweight", defaultSets: 3, defaultReps: 10,
                 iconName: "figure.walk", caloriesPerMinute: 6.5,
                 archetype: .gymBro, workoutStyle: .setsAndReps),

        Exercise(name: "Glute Bridge",
                 description: "Hip extension for glutes and hamstrings. No equipment required.",
                 instructions: ["Lie flat, feet planted", "Drive hips up, squeeze glutes", "Lower slowly"],
                 tips: ["Heels in, toes slightly up"],
                 primaryMuscles: [.glutes], secondaryMuscles: [.hamstrings],
                 category: .strength, difficulty: .beginner,
                 equipment: "Bodyweight", defaultSets: 3, defaultReps: 15,
                 iconName: "figure.strengthtraining.functional", caloriesPerMinute: 4.5,
                 archetype: .gymBro, workoutStyle: .setsAndReps),
    ] }
}
