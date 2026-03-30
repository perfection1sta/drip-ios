import SwiftUI

struct RecentActivityList: View {
    let sessions: [WorkoutSession]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Recent Activity")
                .dripSectionHeader()

            ForEach(sessions) { session in
                RecentActivityRow(session: session)
            }
        }
    }
}

struct RecentActivityRow: View {
    let session: WorkoutSession

    var body: some View {
        DripCard(padding: Spacing.md) {
            HStack {
                // Date circle
                VStack(spacing: 2) {
                    Text(session.startDate.dayOfWeekShort.uppercased())
                        .font(.caption)
                        .foregroundStyle(.textTertiary)
                    Text(session.startDate.dayNumber)
                        .font(.titleSmall)
                        .foregroundStyle(.textPrimary)
                }
                .frame(width: 44)

                Rectangle()
                    .fill(Color.surfaceTertiary)
                    .frame(width: 1, height: 36)
                    .padding(.horizontal, Spacing.xs)

                VStack(alignment: .leading, spacing: 4) {
                    Text(session.workoutName)
                        .font(.labelLarge)
                        .foregroundStyle(.textPrimary)
                    HStack(spacing: Spacing.sm) {
                        Label(session.durationFormatted, systemImage: "clock")
                        Label("\(Int(session.totalVolumeLbs)) lbs", systemImage: "scalemass")
                    }
                    .font(.caption)
                    .foregroundStyle(.textTertiary)
                }

                Spacer()

                // Completion ring
                ProgressRingView(progress: session.completionPercentage,
                                 ringWidth: 3,
                                 size: 32,
                                 foreground: .energyOrange,
                                 showPercent: false)
            }
        }
    }
}
