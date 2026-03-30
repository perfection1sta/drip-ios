import SwiftUI
import SwiftData

@Observable
final class ExerciseLibraryViewModel {
    var allExercises: [Exercise] = []
    var filteredExercises: [Exercise] = []
    var searchText: String = "" {
        didSet { applyFilters() }
    }
    var selectedMuscles: Set<MuscleGroup> = [] {
        didSet { applyFilters() }
    }
    var selectedCategory: ExerciseCategory? = nil {
        didSet { applyFilters() }
    }
    var selectedDifficulty: DifficultyLevel? = nil {
        didSet { applyFilters() }
    }
    var isLoading: Bool = false

    func load(context: ModelContext) {
        let descriptor = FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\.name)])
        allExercises = (try? context.fetch(descriptor)) ?? []
        applyFilters()
    }

    func applyFilters() {
        var results = allExercises

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            results = results.filter {
                $0.name.lowercased().contains(query) ||
                $0.primaryMusclesRaw.joined(separator: " ").lowercased().contains(query)
            }
        }
        if !selectedMuscles.isEmpty {
            results = results.filter { ex in
                !Set(ex.primaryMuscles).isDisjoint(with: selectedMuscles)
            }
        }
        if let cat = selectedCategory {
            results = results.filter { $0.categoryRaw == cat.rawValue }
        }
        if let diff = selectedDifficulty {
            results = results.filter { $0.difficultyRaw == diff.rawValue }
        }
        filteredExercises = results
    }

    func clearFilters() {
        searchText = ""
        selectedMuscles = []
        selectedCategory = nil
        selectedDifficulty = nil
    }

    var hasActiveFilters: Bool {
        !searchText.isEmpty || !selectedMuscles.isEmpty ||
        selectedCategory != nil || selectedDifficulty != nil
    }
}
