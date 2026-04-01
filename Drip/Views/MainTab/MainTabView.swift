import SwiftUI

enum AppTab: CaseIterable {
    case home, library, coach, progress, settings

    var label: String {
        switch self {
        case .home:     return "Home"
        case .library:  return "Library"
        case .coach:    return "Coach"
        case .progress: return "Progress"
        case .settings: return "Settings"
        }
    }
    var icon: String {
        switch self {
        case .home:     return "house.fill"
        case .library:  return "books.vertical.fill"
        case .coach:    return "sparkles"
        case .progress: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
    var isBeta: Bool { self == .coach }
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @Environment(ActiveWorkoutViewModel.self) private var activeWorkoutVM
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:     HomeView()
                case .library:  ExerciseLibraryView()
                case .coach:    AICoachView()
                case .progress: ProgressView()
                case .settings: SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Active workout mini-banner
            if activeWorkoutVM.sessionState == .active || activeWorkoutVM.sessionState == .resting {
                ActiveWorkoutBanner()
                    .padding(.bottom, 88)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            CustomTabBar(selected: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
        .background(Color.surfacePrimary.ignoresSafeArea())
        .fullScreenCover(isPresented: Binding(
            get: { activeWorkoutVM.showWorkoutComplete },
            set: { activeWorkoutVM.showWorkoutComplete = $0 }
        )) {
            WorkoutCompleteView()
        }
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selected: AppTab
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                TabBarItem(tab: tab, isSelected: selected == tab) {
                    HapticManager.shared.selection()
                    withAnimation(reduceMotion ? nil : .snappy) {
                        selected = tab
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.Radius.xxl))
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.md)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -4)
    }
}

struct TabBarItem: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? .energyOrange : .textTertiary)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .animation(.snappy, value: isSelected)

                    if tab.isBeta {
                        Circle()
                            .fill(Color.achieveGold)
                            .frame(width: 6, height: 6)
                            .offset(x: 4, y: -4)
                    }
                }
                Text(tab.label)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .energyOrange : .textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xxs)
            .accessibilityLabel(tab.label + (tab.isBeta ? " (Beta)" : ""))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Active Workout Mini-Banner

struct ActiveWorkoutBanner: View {
    @Environment(ActiveWorkoutViewModel.self) private var vm
    @State private var showFullScreen = false

    var body: some View {
        Button { showFullScreen = true } label: {
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(.energyOrange)
                VStack(alignment: .leading, spacing: 2) {
                    Text(vm.workout?.name ?? "Workout in Progress")
                        .font(.labelLarge)
                        .foregroundStyle(.textPrimary)
                    Text(vm.timerVM.displayTime)
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                        .monospacedDigit()
                }
                Spacer()
                ProgressRingView(progress: vm.completionPercentage,
                                 ringWidth: 3,
                                 size: 28,
                                 foreground: .energyOrange)
            }
            .padding(Spacing.md)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.Radius.lg))
            .padding(.horizontal, Spacing.md)
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showFullScreen) {
            ActiveWorkoutView()
        }
    }
}
