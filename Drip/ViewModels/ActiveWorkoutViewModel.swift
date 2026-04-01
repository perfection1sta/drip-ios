import SwiftUI
import SwiftData

enum SessionState: Equatable {
    case idle, active, resting, paused, completed
}

@Observable
final class ActiveWorkoutViewModel {
    // Session
    var workout: Workout?
    var session: WorkoutSession?
    var sessionState: SessionState = .idle

    // Progress
    var currentExerciseIndex: Int = 0
    var currentSetIndex: Int = 0
    var currentCircuitRound: Int = 1   // for circuit/AMRAP/EMOM workouts
    var completionPercentage: Double = 0.0

    // Per-set input
    var inputReps: Int = 0
    var inputWeight: Double = 0.0
    var inputHoldSeconds: Int = 0      // for timed holds

    // UI state
    var showSetCompletion: Bool = false
    var showWorkoutComplete: Bool = false
    var lastCompletedSetInfo: String = ""
    var newPRExerciseName: String? = nil
    var showPRCelebration: Bool = false

    // Injected
    var timerVM = TimerViewModel()
    private var modelContext: ModelContext?

    // MARK: - Derived helpers

    var currentExercise: WorkoutExercise? {
        guard let workout else { return nil }
        let sorted = workout.sortedExercises
        guard currentExerciseIndex < sorted.count else { return nil }
        return sorted[currentExerciseIndex]
    }

    var totalCircuitRounds: Int {
        workout?.circuitRounds ?? 1
    }

    var isCircuitStyle: Bool {
        guard let workout else { return false }
        return workout.workoutStyle == .circuit || workout.workoutStyle == .amrap || workout.workoutStyle == .emom
    }

    var isTimeBased: Bool {
        guard let ex = currentExercise else { return false }
        // Check if the underlying exercise is time-based
        return ex.workoutStyle == .timedHold || ex.workoutStyle == .emom
    }

    var totalSets: Int {
        workout?.sortedExercises.reduce(0) { $0 + $1.sets } ?? 0
    }

    var completedSetsCount: Int {
        session?.completedSets.filter(\.isCompleted).count ?? 0
    }

    var isLastExercise: Bool {
        guard let workout else { return true }
        return currentExerciseIndex >= workout.sortedExercises.count - 1
    }

    var isLastSet: Bool {
        guard let ex = currentExercise else { return true }
        if isCircuitStyle {
            // In circuit mode, one pass through all exercises = one "set"
            return currentCircuitRound >= totalCircuitRounds
        }
        return currentSetIndex >= ex.sets - 1
    }

    var circuitRoundLabel: String {
        "Round \(currentCircuitRound) of \(totalCircuitRounds)"
    }

    // MARK: - Session Lifecycle

    func startSession(workout: Workout, context: ModelContext) {
        self.workout = workout
        self.modelContext = context
        self.currentExerciseIndex = 0
        self.currentSetIndex = 0
        self.currentCircuitRound = 1
        self.completionPercentage = 0

        let session = WorkoutSession(workoutID: workout.id, workoutName: workout.name)
        context.insert(session)
        self.session = session

        workout.status = .active
        timerVM.startCountUp()
        sessionState = .active

        prefillInputForCurrentExercise()
    }

    func completeSet() {
        guard let ex = currentExercise, let session, let context = modelContext else { return }

        let isHold = isTimeBased
        let set = WorkoutSet(
            setNumber: currentSetIndex + 1,
            exerciseID: ex.exerciseID,
            exerciseName: ex.exerciseName,
            targetReps: isHold ? 1 : ex.reps,
            weightLbs: inputWeight,
            isTimeBased: isHold,
            targetHoldSeconds: isHold ? inputHoldSeconds : nil,
            circuitRound: currentCircuitRound
        )
        set.completedReps = isHold ? 1 : inputReps
        set.completedHoldSeconds = isHold ? inputHoldSeconds : nil
        set.isCompleted = true
        set.completedAt = Date()
        context.insert(set)
        session.completedSets.append(set)
        session.totalVolumeLbs += set.volume

        if isHold {
            lastCompletedSetInfo = "\(inputHoldSeconds)s hold"
        } else {
            lastCompletedSetInfo = "\(inputReps) reps\(inputWeight > 0 ? " @ \(Int(inputWeight)) lbs" : "")"
        }

        checkPersonalRecord(for: set, context: context)
        updateCompletion()

        HapticManager.shared.setComplete()
        withAnimation(.bouncy) { showSetCompletion = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.snappy) { self.showSetCompletion = false }
        }

        advanceAfterSet()
    }

    func skipSet() {
        advanceAfterSet()
    }

    func skipRest() {
        timerVM.reset()
        sessionState = .active
    }

    func pauseWorkout() {
        guard sessionState == .active else { return }
        timerVM.pause()
        sessionState = .paused
    }

    func resumeWorkout() {
        guard sessionState == .paused else { return }
        timerVM.resume()
        sessionState = .active
    }

    func finishWorkout() {
        guard let session, let workout, let context = modelContext else { return }
        session.endDate = Date()
        session.totalDurationSeconds = timerVM.elapsedSeconds
        session.completionPercentage = completionPercentage
        session.caloriesBurned = Double(timerVM.elapsedSeconds / 60) * 6.0

        workout.status = .completed
        workout.isCompleted = true

        timerVM.pause()
        sessionState = .completed

        let profileDesc = FetchDescriptor<UserProfile>()
        if let profile = (try? context.fetch(profileDesc))?.first {
            profile.totalWorkoutsCompleted += 1
        }

        try? context.save()
        withAnimation(.bouncy) { showWorkoutComplete = true }
    }

    func abandonWorkout() {
        timerVM.reset()
        sessionState = .idle
        workout = nil
        session = nil
    }

    // MARK: - Private Helpers

    private func advanceAfterSet() {
        guard let ex = currentExercise, let workout else { return }

        if isCircuitStyle {
            advanceCircuit(workout: workout, restSeconds: ex.exerciseRestSeconds)
        } else {
            advanceLinear(ex: ex)
        }
    }

    private func advanceLinear(ex: WorkoutExercise) {
        if currentSetIndex < ex.sets - 1 {
            currentSetIndex += 1
            startRest(seconds: ex.exerciseRestSeconds)
        } else {
            if isLastExercise {
                finishWorkout()
            } else {
                currentExerciseIndex += 1
                currentSetIndex = 0
                startRest(seconds: ex.exerciseRestSeconds)
                prefillInputForCurrentExercise()
            }
        }
    }

    private func advanceCircuit(workout: Workout, restSeconds: Int) {
        let exercises = workout.sortedExercises
        if currentExerciseIndex < exercises.count - 1 {
            // Move to next exercise in the circuit — short rest
            currentExerciseIndex += 1
            startRest(seconds: min(restSeconds, 20)) // short between exercises
            prefillInputForCurrentExercise()
        } else {
            // Completed one full circuit round
            if currentCircuitRound >= totalCircuitRounds {
                finishWorkout()
            } else {
                currentCircuitRound += 1
                currentExerciseIndex = 0
                startRest(seconds: restSeconds) // full rest between rounds
                prefillInputForCurrentExercise()
            }
        }
    }

    private func startRest(seconds: Int) {
        sessionState = .resting
        timerVM.startCountDown(duration: seconds)
    }

    private func prefillInputForCurrentExercise() {
        guard let ex = currentExercise else { return }
        inputReps = ex.reps
        inputWeight = ex.exerciseEquipment.lowercased() == "bodyweight" ? 0 : 45.0
        inputHoldSeconds = ex.exerciseRestSeconds > 0 ? ex.exerciseRestSeconds : 30
    }

    private func updateCompletion() {
        if isCircuitStyle {
            let totalRounds = Double(totalCircuitRounds)
            let exercises = Double(workout?.sortedExercises.count ?? 1)
            let done = Double((currentCircuitRound - 1)) * exercises + Double(currentExerciseIndex + 1)
            completionPercentage = min(done / (totalRounds * exercises), 1.0)
        } else {
            guard totalSets > 0 else { return }
            completionPercentage = Double(completedSetsCount + 1) / Double(totalSets)
        }
    }

    private func checkPersonalRecord(for set: WorkoutSet, context: ModelContext) {
        guard !set.isTimeBased else { return } // no weight PRs for holds
        let eid = set.exerciseID
        let descriptor = FetchDescriptor<PersonalRecord>(
            predicate: #Predicate { $0.exerciseID == eid }
        )
        let existing = (try? context.fetch(descriptor)) ?? []
        let maxWeight = existing.filter { $0.recordType == .maxWeight }.map(\.value).max() ?? 0

        if set.weightLbs > maxWeight && set.weightLbs > 0 {
            let pr = PersonalRecord(
                exerciseID: set.exerciseID, exerciseName: set.exerciseName,
                recordType: .maxWeight, value: set.weightLbs, previousValue: maxWeight
            )
            context.insert(pr)
            HapticManager.shared.personalRecord()
            newPRExerciseName = set.exerciseName
            withAnimation(.bouncy) { showPRCelebration = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.snappy) { self.showPRCelebration = false }
            }
        }
    }
}
