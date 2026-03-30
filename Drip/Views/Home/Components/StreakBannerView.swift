import SwiftUI

struct StreakBannerView: View {
    let streak: Int

    var body: some View {
        DripCard(padding: Spacing.md) {
            HStack(spacing: Spacing.md) {
                // Fire icon with glow
                ZStack {
                    Circle()
                        .fill(RadialGradient.glowEffect(color: .achieveGold, radius: 30))
                        .frame(width: 60, height: 60)
                    Text("🔥")
                        .font(.system(size: 32))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(streak) Day Streak")
                        .font(.titleMedium)
                        .foregroundStyle(.textPrimary)
                    Text(streak == 0
                         ? "Start your streak today!"
                         : streak == 1 ? "Great start — keep going!"
                         : "You're on fire! Don't stop now.")
                        .font(.bodySmall)
                        .foregroundStyle(.textSecondary)
                }
                Spacer()

                // Streak dots (last 7 days)
                StreakDotsView(streak: streak)
            }
        }
    }
}

struct StreakDotsView: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<7) { i in
                Circle()
                    .fill(i < (streak % 7) ? Color.achieveGold : Color.surfaceTertiary)
                    .frame(width: 8, height: 8)
            }
        }
    }
}
