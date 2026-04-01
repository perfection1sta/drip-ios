import Foundation

// MARK: - AI Response Parser
// Extracts plain text and optional workout JSON from Claude's responses.

struct ParsedAIResponse {
    let text: String                    // always present — the conversational reply
    let suggestedWorkout: WorkoutPlan?  // present when Claude includes a <workout_plan> block
}

struct WorkoutPlan: Codable {
    let name: String
    let style: String
    let estimatedMinutes: Int
    let rounds: Int?
    let exercises: [WorkoutPlanExercise]
}

struct WorkoutPlanExercise: Codable {
    let name: String
    let sets: Int
    let reps: Int?
    let holdSeconds: Int?
    let restSeconds: Int?
    let notes: String?
}

enum AIResponseParser {

    static func parse(_ rawContent: String) -> ParsedAIResponse {
        // Extract <workout_plan>...</workout_plan> block if present
        var workoutPlan: WorkoutPlan?
        var cleanText = rawContent

        if let range = rawContent.range(of: "<workout_plan>"),
           let endRange = rawContent.range(of: "</workout_plan>") {
            let jsonStart = rawContent.index(range.upperBound, offsetBy: 0)
            let jsonEnd = endRange.lowerBound
            let jsonString = String(rawContent[jsonStart..<jsonEnd]).trimmingCharacters(in: .whitespacesAndNewlines)

            if let data = jsonString.data(using: .utf8),
               let plan = try? JSONDecoder().decode(WorkoutPlan.self, from: data) {
                workoutPlan = plan
            }

            // Remove the workout_plan block from display text
            cleanText = rawContent.replacingOccurrences(
                of: "<workout_plan>\(rawContent[jsonStart..<endRange.upperBound])",
                with: ""
            )
            // Simpler fallback: just remove the tags
            cleanText = cleanText
                .replacingOccurrences(of: "<workout_plan>", with: "")
                .replacingOccurrences(of: "</workout_plan>", with: "")
                .replacingOccurrences(of: jsonString, with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return ParsedAIResponse(text: cleanText, suggestedWorkout: workoutPlan)
    }

    /// Converts a WorkoutPlan from Claude into a SwiftData Workout model.
    static func buildWorkout(from plan: WorkoutPlan,
                              exercises: [Exercise],
                              profile: UserProfile?) -> Workout? {
        let style = WorkoutStyle(rawValue: plan.style) ?? .setsAndReps
        let archetype = profile?.archetype ?? .gymBro
        let difficulty = profile?.fitnessLevel ?? .intermediate
        let rounds = plan.rounds ?? 1

        var workoutExercises: [WorkoutExercise] = []
        for (index, planEx) in plan.exercises.enumerated() {
            // Try to match to an existing exercise by name (case-insensitive)
            let match = exercises.first {
                $0.name.lowercased().contains(planEx.name.lowercased()) ||
                planEx.name.lowercased().contains($0.name.lowercased())
            }

            if let ex = match {
                let we = WorkoutExercise(
                    sortOrder: index,
                    exercise: ex,
                    customSets: planEx.sets,
                    customReps: planEx.reps ?? ex.defaultReps
                )
                workoutExercises.append(we)
            }
            // Skip exercises not found in library — keeps only safe, known exercises
        }

        guard !workoutExercises.isEmpty else { return nil }

        return Workout(
            name: plan.name,
            generatedDate: Date(),
            estimatedDurationMinutes: plan.estimatedMinutes,
            difficulty: difficulty,
            focusMuscles: [],
            exercises: workoutExercises,
            archetype: archetype,
            workoutStyle: style,
            isAIGenerated: true,
            circuitRounds: rounds
        )
    }
}
