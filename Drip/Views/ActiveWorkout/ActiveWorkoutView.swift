import SwiftUI

struct ActiveWorkoutView: View {
    @Environment(ActiveWorkoutViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showExitConfirm = false

    var body: some View {
        ZStack {
            // Animated background
            AnimatedGradientBackground(category: vm.currentExercise?.exerciseCategoryRaw)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar (top)
                WorkoutProgressBar(progress: vm.completionPercentage)
                    .padding(.top, Spacing.md)

                // Header
                workoutHeader
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.sm)

                Spacer()

                // Current exercise hero
                if let exercise = vm.currentExercise {
                    ExerciseHeroView(workoutExercise: exercise,
                                     exerciseIndex: vm.currentExerciseIndex,
                                     totalExercises: vm.workout?.sortedExercises.count ?? 0)
                        .padding(.horizontal, Spacing.md)
                }

                Spacer()

                // Set tracker
                if let exercise = vm.currentExercise {
                    SetTrackerView(workoutExercise: exercise,
                                   currentSet: vm.currentSetIndex)
                        .padding(.horizontal, Spacing.md)
                }

                // Input + complete button
                setInputSection
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.huge)
            }

            // Rest timer overlay
            if vm.sessionState == .resting {
                RestTimerView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Set completion burst
            if vm.showSetCompletion {
                SetCompletionOverlay(info: vm.lastCompletedSetInfo)
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
                    .allowsHitTesting(false)
            }

            // PR celebration
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
            Button("Abandon", role: .destructive) {
                vm.abandonWorkout()
                dismiss()
            }
            Button("Continue", role: .cancel) {}
        } message: {
            Text("You've completed \(Int(vm.completionPercentage * 100))% of the workout.")
        }
    }

    private var workoutHeader: some View {
        HStack {
            Button {
                HapticManager.shared.light()
                showExitConfirm = true
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            VStack(spacing: 2) {
                Text(vm.workout?.name ?? "Workout")
                    .font(.titleSmall)
                    .foregroundStyle(.white)
                Text(vm.timerVM.displayTime)
                    .font(.bodySmall)
                    .foregroundStyle(.white.opacity(0.7))
                    .monospacedDigit()
            }

            Spacer()

            Button {
                vm.sessionState == .paused ? vm.resumeWorkout() : vm.pauseWorkout()
                HapticManager.shared.light()
            } label: {
                Image(systemName: vm.sessionState == .paused ? "play.circle.fill" : "pause.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }

    @State private var inputReps: Int = 0
    @State private var inputWeight: Double = 0

    private var setInputSection: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.xl) {
                // Reps stepper
                VStack(spacing: 4) {
                    Text("Reps")
                        .font(.labelSmall)
                        .foregroundStyle(.white.opacity(0.7))
                    HStack(spacing: Spacing.md) {
                        stepperButton(icon: "minus", action: {
                            if vm.inputReps > 0 { vm.inputReps -= 1 }
                        })
                        Text("\(vm.inputReps)")
                            .font(.statSmall)
                            .foregroundStyle(.white)
                            .monospacedDigit()
                            .frame(minWidth: 44)
                        stepperButton(icon: "plus", action: { vm.inputReps += 1 })
                    }
                }

                Rectangle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 1, height: 48)

                // Weight stepper
                VStack(spacing: 4) {
                    Text("Weight (lbs)")
                        .font(.labelSmall)
                        .foregroundStyle(.white.opacity(0.7))
                    HStack(spacing: Spacing.md) {
                        stepperButton(icon: "minus", action: {
                            if vm.inputWeight >= 5 { vm.inputWeight -= 5 }
                        })
                        Text(vm.inputWeight == 0 ? "BW" : "\(Int(vm.inputWeight))")
                            .font(.statSmall)
                            .foregroundStyle(.white)
                            .monospacedDigit()
                            .frame(minWidth: 44)
                        stepperButton(icon: "plus", action: { vm.inputWeight += 5 })
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: Spacing.Radius.lg))

            DripButton("Complete Set",
                       icon: "checkmark") {
                vm.completeSet()
            }

            DripButton("Skip Set", style: .ghost) {
                vm.skipSet()
                HapticManager.shared.light()
            }
        }
    }

    private func stepperButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.15))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
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
