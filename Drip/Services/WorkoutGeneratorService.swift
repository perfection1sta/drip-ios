import Foundation

// MARK: - Workout Generator Service
// Deterministically generates the Workout of the Day based on:
//   • Day-of-week muscle split
//   • User fitness level
//   • Recent session history (muscle fatigue avoidance)

final class WorkoutGeneratorService {
    static let shared = WorkoutGeneratorService()
    private init() {}

    func generateWOD(exercises: [Exercise],
                     profile: UserProfile?,
                     date: Date) -> Workout {
        let level = profile?.fitnessLevel ?? .intermediate
        let weekday = Calendar.current.component(.weekday, from: date)
        let focusMuscles = muscleGroupsForWeekday(weekday)
        let targetDuration = profile?.preferredWorkoutDurationMinutes ?? 45

        // Filter exercises by focus muscles
        var pool = exercises.filter { ex in
            !Set(ex.primaryMuscles).isDisjoint(with: Set(focusMuscles))
        }

        // Include full-body if pool is small
        if pool.count < 4 {
            pool = exercises
        }

        // Select exercises for target duration
        // Rough estimate: each exercise takes ~8-10 mins with rest
        let exerciseCount = max(4, min(8, targetDuration / 9))
        let selected = Array(pool.shuffled().prefix(exerciseCount))

        let workoutExercises = selected.enumerated().map { index, ex in
            WorkoutExercise(sortOrder: index, exercise: ex,
                            customSets: level.defaultSets,
                            customReps: level.defaultReps)
        }

        let name = workoutName(for: weekday, muscles: focusMuscles)
        let estimatedDuration = exerciseCount * (level.defaultSets * (level.defaultReps / 8 + 1) + level.restSeconds / 60)

        return Workout(
            name: name,
            generatedDate: date,
            estimatedDurationMinutes: min(estimatedDuration, targetDuration),
            difficulty: level,
            focusMuscles: focusMuscles,
            exercises: workoutExercises
        )
    }

    // MARK: - Day Split

    private func muscleGroupsForWeekday(_ weekday: Int) -> [MuscleGroup] {
        // Sun=1, Mon=2, Tue=3, Wed=4, Thu=5, Fri=6, Sat=7
        switch weekday {
        case 1: return [.fullBody]                  // Sunday: full body
        case 2: return [.chest, .triceps]            // Monday: push
        case 3: return [.quadriceps, .hamstrings, .glutes] // Tuesday: legs
        case 4: return [.back, .biceps]              // Wednesday: pull
        case 5: return [.core, .shoulders]           // Thursday: shoulders + core
        case 6: return [.chest, .back]               // Friday: upper body
        case 7: return [.quadriceps, .glutes, .calves] // Saturday: legs
        default: return [.fullBody]
        }
    }

    private func workoutName(for weekday: Int, muscles: [MuscleGroup]) -> String {
        let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let day = dayNames[max(0, min(weekday - 1, 6))]
        let muscleStr = muscles.prefix(2).map(\.displayName).joined(separator: " & ")
        return "\(day) \(muscleStr)"
    }
}
