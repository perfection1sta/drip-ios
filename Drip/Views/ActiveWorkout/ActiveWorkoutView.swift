import SwiftUI

struct ActiveWorkoutView: View {
    @Environment(ActiveWorkoutViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showExitConfirm = false

    var body: some View {
        ZStack {
            AnimatedGradientBackground(category: vm.currentExercise?.exerciseCategoryRaw)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                workoutHeader
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.md)

                Spacer()

                if let exercise = vm.currentExercise {
                    exerciseSection(exercise)
                }

                Spacer()

                bottomControls
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xxl)
            }

            // Set timer overlay
            if vm.showSetTimer, let exercise = vm.currentExercise {
                SetTimerView(exercise: exercise, setNumber: vm.currentSetIndex + 1)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }

            // Rest timer overlay
            if vm.sessionState == .resting {
                RestTimerView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(2)
            }

            if vm.showSetCompletion {
                SetCompletionOverlay(info: vm.lastCompletedSetInfo)
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
                    .allowsHitTesting(false)
            }

            if vm.showPRCelebration {
                PRCelebrationBanner(exerciseName: vm.newPRExerciseName ?? "")
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: vm.timerVM.hasFinished) { _, finished in
            if finished && vm.sessionState == .resting {
                withAnimation(.snappy) { vm.skipRest() }
            }
        }
        .confirmationDialog("Exit Workout?",
                            isPresented: $showExitConfirm,
                            titleVisibility: .visible) {
            Button("Finish & Save", role: .none) { vm.finishWorkout() }
            Button("Abandon", role: .destructive) { vm.abandonWorkout(); dismiss() }
            Button("Continue", role: .cancel) {}
        } message: {
            Text("You've completed \(Int(vm.completionPercentage * 100))% of the workout.")
        }
    }

    // MARK: Header — minimal: X | workout name + timer | pause
    private var workoutHeader: some View {
        HStack {
            Button {
                HapticManager.shared.light()
                showExitConfirm = true
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.1))
                    .clipShape(Circle())
            }

            Spacer()

            VStack(spacing: 2) {
                Text(vm.workout?.name ?? "Workout")
                    .font(.labelLarge)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(1)
                Text(vm.timerVM.displayTime)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .monospacedDigit()
            }

            Spacer()

            Button {
                vm.sessionState == .paused ? vm.resumeWorkout() : vm.pauseWorkout()
                HapticManager.shared.light()
            } label: {
                Image(systemName: vm.sessionState == .paused ? "play.fill" : "pause.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
    }

    // MARK: Exercise section — icon, name, set pill
    @ViewBuilder
    private func exerciseSection(_ exercise: WorkoutExercise) -> some View {
        let total = vm.workout?.sortedExercises.count ?? 1

        VStack(spacing: Spacing.xl) {
            // Icon glow
            ZStack {
                Circle()
                    .fill(RadialGradient.glowEffect(color: muscleColor(exercise), radius: 100))
                    .frame(width: 180, height: 180)
                Image(systemName: exercise.exerciseIconName)
                    .font(.system(size: 72, weight: .ultraLight))
                    .foregroundStyle(muscleColor(exercise))
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(spacing: Spacing.sm) {
                // Exercise counter (subtle)
                Text("\(vm.currentExerciseIndex + 1) of \(total)")
                    .font(.labelSmall)
                    .foregroundStyle(.white.opacity(0.4))

                // Name
                Text(exercise.exerciseName)
                    .font(.displaySmall)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
                    .lineLimit(2)
                    .padding(.horizontal, Spacing.lg)

                // Set progress dots
                setProgressDots(exercise: exercise)
            }
        }
        .id(exercise.id)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }

    // MARK: Set progress — minimal dot row
    private func setProgressDots(exercise: WorkoutExercise) -> some View {
        HStack(spacing: Spacing.xs) {
            ForEach(0..<exercise.sets, id: \.self) { i in
                let isDone = i < vm.currentSetIndex
                let isCurrent = i == vm.currentSetIndex
                ZStack {
                    Capsule()
                        .fill(isDone ? muscleColor(exercise) : (isCurrent ? .white.opacity(0.4) : .white.opacity(0.12)))
                        .frame(width: isCurrent ? 28 : 8, height: 8)
                    if isCurrent {
                        Text("Set \(i + 1)")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .animation(.snappy, value: vm.currentSetIndex)
            }
        }
    }

    // MARK: Bottom controls — reps/weight + complete
    private var bottomControls: some View {
        VStack(spacing: Spacing.md) {
            // Reps + Weight
            HStack(spacing: 0) {
                inputControl(label: "Reps",
                             value: "\(vm.inputReps)",
                             onMinus: { if vm.inputReps > 0 { vm.inputReps -= 1 } },
                             onPlus: { vm.inputReps += 1 })

                Rectangle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 1, height: 56)

                inputControl(label: "Weight (lbs)",
                             value: vm.inputWeight == 0 ? "BW" : "\(Int(vm.inputWeight))",
                             onMinus: { if vm.inputWeight >= 5 { vm.inputWeight -= 5 } },
                             onPlus: { vm.inputWeight += 5 })
            }
            .background(.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: Spacing.Radius.xl))

            // Start Set → opens timer; Complete Set → logs without timer
            HStack(spacing: Spacing.sm) {
                DripButton("Start Set", icon: "timer") {
                    HapticManager.shared.medium()
                    withAnimation(.snappy) { vm.showSetTimer = true }
                }

                Button {
                    vm.completeSet()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 52, height: 52)
                        .background(.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(ScaleDownButtonStyle())
            }

            // Skip — text link only
            Button("Skip Set") {
                vm.skipSet()
                HapticManager.shared.light()
            }
            .font(.bodySmall)
            .foregroundStyle(.white.opacity(0.35))
        }
    }

    // MARK: Input control (reps or weight)
    private func inputControl(label: String, value: String,
                              onMinus: @escaping () -> Void,
                              onPlus: @escaping () -> Void) -> some View {
        HStack(spacing: Spacing.sm) {
            Button(action: { HapticManager.shared.light(); onMinus() }) {
                Image(systemName: "minus")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            VStack(spacing: 2) {
                Text(value)
                    .font(.statSmall)
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .frame(minWidth: 40)
                    .contentTransition(.numericText())
                Text(label)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.4))
            }

            Button(action: { HapticManager.shared.light(); onPlus() }) {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
    }

    private func muscleColor(_ exercise: WorkoutExercise) -> Color {
        exercise.primaryMuscles.first?.color ?? .energyOrange
    }
}

// MARK: - Animated Gradient Background

struct AnimatedGradientBackground: View {
    let category: String?
    @State private var phase: Double = 0

    private var baseColor: Color {
        switch ExerciseCategory(rawValue: category ?? "") {
        case .cardio, .hiit: return .energyRed
        case .mobility, .recovery: return .wellnessTeal
        default: return Color(red: 0.1, green: 0.05, blue: 0.15)
        }
    }

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.06, blue: 0.09)
            baseColor.opacity(0.2)
                .hueRotation(.degrees(phase * 15))
                .animation(.linear(duration: 8).repeatForever(autoreverses: true), value: phase)
        }
        .onAppear { phase = 1 }
    }
}

private struct ScaleDownButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.snappy, value: configuration.isPressed)
    }
}
