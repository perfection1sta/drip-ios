import SwiftUI

struct ExerciseFilterSheet: View {
    @Environment(ExerciseLibraryViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var bindableVM = vm
        NavigationStack {
            List {
                // Muscle groups
                Section("Muscle Group") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: Spacing.xs) {
                        ForEach(MuscleGroup.allCases) { muscle in
                            Toggle(isOn: Binding(
                                get: { vm.selectedMuscles.contains(muscle) },
                                set: { on in
                                    if on { vm.selectedMuscles.insert(muscle) }
                                    else  { vm.selectedMuscles.remove(muscle) }
                                }
                            )) {
                                DripBadge(text: muscle.displayName,
                                          color: muscle.color,
                                          icon: muscle.sfSymbol)
                            }
                            .toggleStyle(.button)
                        }
                    }
                    .listRowBackground(Color.surfacePrimary)
                    .listRowInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
                }

                // Category
                Section("Category") {
                    ForEach(ExerciseCategory.allCases) { cat in
                        HStack {
                            DripBadge(text: cat.displayName,
                                      color: cat.color,
                                      icon: cat.sfSymbol)
                            Spacer()
                            if vm.selectedCategory == cat {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.energyOrange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.selectedCategory = vm.selectedCategory == cat ? nil : cat
                        }
                    }
                }

                // Difficulty
                Section("Difficulty") {
                    ForEach(DifficultyLevel.allCases) { diff in
                        HStack {
                            Text(diff.displayName)
                                .foregroundStyle(diff.color)
                            HStack(spacing: 3) {
                                ForEach(0..<diff.stars, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 11))
                                        .foregroundStyle(diff.color)
                                }
                            }
                            Spacer()
                            if vm.selectedDifficulty == diff {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.energyOrange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.selectedDifficulty = vm.selectedDifficulty == diff ? nil : diff
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.surfacePrimary)
            .navigationTitle("Filter Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.energyOrange)
                }
                ToolbarItem(placement: .topBarLeading) {
                    if vm.hasActiveFilters {
                        Button("Clear") { vm.clearFilters() }
                            .foregroundStyle(.textSecondary)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
