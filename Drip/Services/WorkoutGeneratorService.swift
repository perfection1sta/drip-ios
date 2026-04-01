import Foundation

// MARK: - Workout Generator Service
// Archetype-aware WOD generation. Each archetype uses a different strategy:
//   • Gym Bro: push/pull/legs split, sets & reps
//   • Functional Fitness: circuit/AMRAP/EMOM rotation, compound movements
//   • Pilates & Yoga: flow sequences with warm-up → core → flexibility → cooldown

final class WorkoutGeneratorService {
    static let shared = WorkoutGeneratorService()
    private init() {}

    func generateWOD(exercises: [Exercise],
                     profile: UserProfile?,
                     date: Date) -> Workout {
        let archetype = profile?.archetype ?? .gymBro
        switch archetype {
        case .gymBro:
            return generateGymBroWOD(exercises: exercises, profile: profile, date: date)
        case .functionalFitness:
            return generateFunctionalWOD(exercises: exercises, profile: profile, date: date)
        case .pilatesYoga:
            return generatePilatesWOD(exercises: exercises, profile: profile, date: date)
        }
    }

    // MARK: - Gym Bro: Push / Pull / Legs Split

    private func generateGymBroWOD(exercises: [Exercise],
                                    profile: UserProfile?,
                                    date: Date) -> Workout {
        let level = profile?.fitnessLevel ?? .intermediate
        let weekday = Calendar.current.component(.weekday, from: date)
        let focusMuscles = gymBroMusclesForWeekday(weekday)
        let targetDuration = profile?.preferredWorkoutDurationMinutes ?? 45

        var pool = exercises.filter { ex in
            !Set(ex.primaryMuscles).isDisjoint(with: Set(focusMuscles)) &&
            ex.workoutStyle != .flowSequence &&
            ex.workoutStyle != .timedHold
        }
        if pool.count < 4 { pool = exercises.filter { $0.archetype == .gymBro } }

        let exerciseCount = max(4, min(8, targetDuration / 9))
        let selected = Array(pool.shuffled().prefix(exerciseCount))

        let workoutExercises = selected.enumerated().map { index, ex in
            WorkoutExercise(sortOrder: index, exercise: ex,
                            customSets: level.defaultSets,
                            customReps: level.defaultReps)
        }

        let name = gymBroWorkoutName(weekday: weekday, muscles: focusMuscles)
        let estimatedDuration = exerciseCount * (level.defaultSets * 3 + level.restSeconds / 60)

        return Workout(
            name: name, generatedDate: date,
            estimatedDurationMinutes: min(estimatedDuration, targetDuration),
            difficulty: level, focusMuscles: focusMuscles,
            exercises: workoutExercises,
            archetype: .gymBro, workoutStyle: .setsAndReps,
            circuitRounds: 1
        )
    }

    private func gymBroMusclesForWeekday(_ weekday: Int) -> [MuscleGroup] {
        switch weekday {
        case 1: return [.chest, .shoulders, .triceps]    // Sunday: push
        case 2: return [.back, .biceps]                  // Monday: pull
        case 3: return [.quadriceps, .hamstrings, .glutes] // Tuesday: legs
        case 4: return [.chest, .triceps]                // Wednesday: push
        case 5: return [.back, .biceps]                  // Thursday: pull
        case 6: return [.quadriceps, .glutes, .calves]   // Friday: legs
        case 7: return [.core, .shoulders]               // Saturday: accessory
        default: return [.fullBody]
        }
    }

    private func gymBroWorkoutName(weekday: Int, muscles: [MuscleGroup]) -> String {
        switch weekday {
        case 1, 4: return "Push Day"
        case 2, 5: return "Pull Day"
        case 3, 6: return "Leg Day"
        case 7:    return "Accessory & Core"
        default:   return "Full Body"
        }
    }

    // MARK: - Functional Fitness: Circuit / AMRAP / EMOM Rotation

    private func generateFunctionalWOD(exercises: [Exercise],
                                        profile: UserProfile?,
                                        date: Date) -> Workout {
        let level = profile?.fitnessLevel ?? .intermediate
        let targetDuration = profile?.preferredWorkoutDurationMinutes ?? 40

        // Rotate between circuit, AMRAP, and EMOM based on day of week
        let weekday = Calendar.current.component(.weekday, from: date)
        let style: WorkoutStyle = [WorkoutStyle.circuit, .amrap, .emom][weekday % 3]

        let pool = exercises.filter { $0.archetype == .functionalFitness || $0.archetype == .gymBro }
            .filter { $0.workoutStyle == .circuit || $0.workoutStyle == .setsAndReps || $0.workoutStyle == .amrap }

        let exerciseCount: Int
        let rounds: Int
        switch style {
        case .circuit:
            exerciseCount = 5
            rounds = level == .beginner ? 3 : (level == .intermediate ? 4 : 5)
        case .amrap:
            exerciseCount = 4
            rounds = 1 // AMRAP rounds are time-capped, tracked differently
        case .emom:
            exerciseCount = 4
            rounds = level == .beginner ? 8 : (level == .intermediate ? 10 : 12)
        default:
            exerciseCount = 5
            rounds = 3
        }

        let selected = Array(pool.shuffled().prefix(exerciseCount))
        let workoutExercises = selected.enumerated().map { index, ex in
            WorkoutExercise(sortOrder: index, exercise: ex,
                            customSets: rounds,
                            customReps: level == .beginner ? 10 : (level == .intermediate ? 12 : 15))
        }

        let name = functionalWorkoutName(style: style, weekday: weekday)
        return Workout(
            name: name, generatedDate: Date(),
            estimatedDurationMinutes: targetDuration,
            difficulty: level, focusMuscles: [.fullBody],
            exercises: workoutExercises,
            archetype: .functionalFitness, workoutStyle: style,
            circuitRounds: rounds
        )
    }

    private func functionalWorkoutName(style: WorkoutStyle, weekday: Int) -> String {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let day = days[max(0, min(weekday - 1, 6))]
        switch style {
        case .circuit: return "\(day) Circuit"
        case .amrap:   return "\(day) AMRAP"
        case .emom:    return "\(day) EMOM"
        default:       return "\(day) Functional"
        }
    }

    // MARK: - Pilates & Yoga: Flow Sequence

    private func generatePilatesWOD(exercises: [Exercise],
                                     profile: UserProfile?,
                                     date: Date) -> Workout {
        let level = profile?.fitnessLevel ?? .intermediate
        let targetDuration = profile?.preferredWorkoutDurationMinutes ?? 45
        let weekday = Calendar.current.component(.weekday, from: date)

        let pool = exercises.filter { $0.archetype == .pilatesYoga }

        // Build a structured flow: warm-up → core block → lower body → flexibility → cooldown
        let warmUp   = pool.filter { $0.category == .mobility || $0.workoutStyle == .flowSequence }.shuffled().prefix(2)
        let coreWork = pool.filter { $0.primaryMuscles.contains(.core) }.shuffled().prefix(3)
        let lower    = pool.filter { $0.primaryMuscles.contains(.glutes) || $0.primaryMuscles.contains(.quadriceps) }.shuffled().prefix(2)
        let flex     = pool.filter { $0.category == .mobility && $0.workoutStyle == .timedHold }.shuffled().prefix(2)
        let coolDown = pool.filter { $0.name.contains("Child") || $0.name.contains("Twist") || $0.name.contains("Fold") }.shuffled().prefix(1)

        var sequence: [Exercise] = Array(warmUp) + Array(coreWork) + Array(lower) + Array(flex) + Array(coolDown)
        // De-duplicate
        var seen = Set<UUID>()
        sequence = sequence.filter { seen.insert($0.id).inserted }
        // Pad if flow is short
        if sequence.count < 5 {
            let extras = pool.filter { !seen.contains($0.id) }.shuffled().prefix(5 - sequence.count)
            sequence += Array(extras)
        }

        let workoutExercises = sequence.enumerated().map { index, ex in
            WorkoutExercise(sortOrder: index, exercise: ex,
                            customSets: level == .beginner ? 2 : 3,
                            customReps: ex.isTimeBased ? 1 : 10)
        }

        let names = ["Flow & Restore", "Core & Tone", "Strength Flow", "Balance & Flex", "Total Body Flow", "Mindful Movement", "Power & Flow"]
        let name = names[weekday % names.count]

        return Workout(
            name: name, generatedDate: date,
            estimatedDurationMinutes: targetDuration,
            difficulty: level, focusMuscles: [.core, .fullBody],
            exercises: workoutExercises,
            archetype: .pilatesYoga, workoutStyle: .flowSequence,
            circuitRounds: level == .beginner ? 1 : 2
        )
    }
}
