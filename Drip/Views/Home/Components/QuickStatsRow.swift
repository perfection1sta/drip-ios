import SwiftUI

struct QuickStatsRow: View {
    let weeklyCount: Int
    let weeklyGoal: Int
    let streak: Int

    var body: some View {
        HStack(spacing: Spacing.sm) {
            StatPill(label: "This Week",
                     value: "\(weeklyCount)/\(weeklyGoal)",
                     unit: "workouts",
                     accentColor: .energyOrange)

            StatPill(label: "Streak",
                     value: "\(streak)",
                     unit: "days",
                     accentColor: .achieveGold)

            StatPill(label: "Today",
                     value: weeklyCount > 0 ? "Done" : "Ready",
                     unit: weeklyCount > 0 ? "✓" : "→",
                     accentColor: weeklyCount > 0 ? .success : .wellnessTeal)
        }
    }
}
