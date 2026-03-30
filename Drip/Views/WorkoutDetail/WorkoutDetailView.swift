import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    let namespace: Namespace.ID

    @Environment(ActiveWorkoutViewModel.self) private var activeVM
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var showActiveWorkout = false
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.darkSurface.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.xl) {
                        WorkoutHeaderView(workout: workout)
                            .opacity(appeared ? 1 : 0)
                            .animation(.staggered(0), value: appeared)

                        exerciseList

                        DripButton("Start Workout",
                                   icon: "play.fill") {
                            HapticManager.shared.medium()
                            activeVM.startSession(workout: workout, context: context)
                            showActiveWorkout = true
                        }
                        .opacity(workout.isCompleted ? 0.5 : 1)
                        .disabled(workout.isCompleted)
                        .padding(.bottom, Spacing.huge)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.textSecondary)
                    }
                }
            }
        }
        .onAppear { withAnimation { appeared = true } }
        .fullScreenCover(isPresented: $showActiveWorkout) {
            ActiveWorkoutView()
        }
    }

    private var exerciseList: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Exercises")
                .dripSectionHeader()

            ForEach(Array(workout.sortedExercises.enumerated()), id: \.element.id) { index, we in
                ExerciseRowView(workoutExercise: we, index: index + 1)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.staggered(index + 1), value: appeared)
            }
        }
    }
}
