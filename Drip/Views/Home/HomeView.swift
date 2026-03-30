import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(HomeViewModel.self) private var vm
    @Environment(ActiveWorkoutViewModel.self) private var activeVM
    @Environment(\.modelContext) private var context
    @Namespace private var heroNamespace

    @State private var showWorkoutDetail = false
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.darkSurface.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.xl) {
                        // Header
                        headerSection
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : -16)
                            .animation(.staggered(0), value: appeared)

                        // Streak
                        StreakBannerView(streak: vm.currentStreak)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.staggered(1), value: appeared)

                        // Today's workout hero card
                        if let workout = vm.todayWorkout {
                            TodayWorkoutCard(workout: workout, namespace: heroNamespace) {
                                showWorkoutDetail = true
                            }
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.staggered(2), value: appeared)
                        } else {
                            GeneratingWorkoutCard()
                                .opacity(appeared ? 1 : 0)
                                .animation(.staggered(2), value: appeared)
                        }

                        // Quick stats
                        QuickStatsRow(
                            weeklyCount: vm.weeklySessionCount,
                            weeklyGoal: vm.weeklyGoal,
                            streak: vm.currentStreak
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.staggered(3), value: appeared)

                        // Recent activity
                        if !vm.recentSessions.isEmpty {
                            RecentActivityList(sessions: vm.recentSessions)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(.staggered(4), value: appeared)
                        }

                        // Quote
                        motivationalQuote
                            .opacity(appeared ? 1 : 0)
                            .animation(.staggered(5), value: appeared)

                        Spacer(minLength: Spacing.huge)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showWorkoutDetail) {
                if let workout = vm.todayWorkout {
                    WorkoutDetailView(workout: workout, namespace: heroNamespace)
                }
            }
            .onAppear {
                vm.load(context: context)
                withAnimation { appeared = true }
            }
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good \(timeOfDayGreeting),")
                    .font(.bodyMedium)
                    .foregroundStyle(.textSecondary)
                Text("Ready to Drip? 💧")
                    .font(.displaySmall)
                    .foregroundStyle(.textPrimary)
            }
            Spacer()
            // Streak fire badge
            if vm.currentStreak > 0 {
                VStack(spacing: 2) {
                    Text("🔥")
                        .font(.system(size: 24))
                    Text("\(vm.currentStreak)")
                        .font(.labelLarge)
                        .foregroundStyle(.achieveGold)
                }
                .padding(Spacing.sm)
                .background(Color.achieveGold.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: Spacing.Radius.md))
            }
        }
    }

    private var motivationalQuote: some View {
        DripCard(glassEffect: true) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.energyOrange)
                Text(vm.motivationalQuote)
                    .font(.bodySmall)
                    .foregroundStyle(.textSecondary)
                    .italic()
            }
        }
    }

    private var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "morning"
        case 12..<17: return "afternoon"
        default: return "evening"
        }
    }
}
