import SwiftUI

struct ExerciseLibraryView: View {
    @Environment(ExerciseLibraryViewModel.self) private var vm
    @Environment(\.modelContext) private var context

    @State private var showFilters = false
    @State private var selectedExercise: Exercise? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.darkSurface.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.sm)

                    // Filter chips
                    if vm.hasActiveFilters {
                        activeFiltersRow
                            .padding(.horizontal, Spacing.md)
                            .padding(.top, Spacing.xs)
                    }

                    // Grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: Spacing.sm),
                            GridItem(.flexible(), spacing: Spacing.sm)
                        ], spacing: Spacing.sm) {
                            ForEach(Array(vm.filteredExercises.enumerated()), id: \.element.id) { idx, ex in
                                ExerciseGridCard(exercise: ex)
                                    .onTapGesture {
                                        HapticManager.shared.light()
                                        selectedExercise = ex
                                    }
                                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                                    .animation(.staggered(idx % 20), value: vm.filteredExercises.count)
                            }
                        }
                        .padding(Spacing.md)
                        .padding(.bottom, Spacing.huge)
                    }
                }
            }
            .navigationTitle("Exercise Library")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.light()
                        showFilters = true
                    } label: {
                        Label("Filter", systemImage: vm.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundStyle(vm.hasActiveFilters ? .energyOrange : .textSecondary)
                    }
                }
            }
        }
        .onAppear { vm.load(context: context) }
        .sheet(isPresented: $showFilters) {
            ExerciseFilterSheet()
        }
        .sheet(item: $selectedExercise) { ex in
            ExerciseFullDetailView(exercise: ex)
        }
    }

    private var searchBar: some View {
        @Bindable var bindableVM = vm
        return HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.textTertiary)
            TextField("Search exercises…", text: $bindableVM.searchText)
                .font(.bodyMedium)
                .foregroundStyle(.textPrimary)
            if !vm.searchText.isEmpty {
                Button {
                    vm.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.textTertiary)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.Radius.xl))
    }

    private var activeFiltersRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                ForEach(Array(vm.selectedMuscles)) { muscle in
                    filterChip(muscle.displayName, color: muscle.color) {
                        vm.selectedMuscles.remove(muscle)
                    }
                }
                if let cat = vm.selectedCategory {
                    filterChip(cat.displayName, color: cat.color) {
                        vm.selectedCategory = nil
                    }
                }
                if let diff = vm.selectedDifficulty {
                    filterChip(diff.displayName, color: diff.color) {
                        vm.selectedDifficulty = nil
                    }
                }
                Button("Clear all") { vm.clearFilters() }
                    .font(.labelSmall)
                    .foregroundStyle(.energyOrange)
            }
        }
    }

    private func filterChip(_ text: String, color: Color, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Text(text).font(.labelSmall)
            Button(action: onRemove) {
                Image(systemName: "xmark").font(.system(size: 9, weight: .bold))
            }
        }
        .foregroundStyle(color)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 5)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }
}
