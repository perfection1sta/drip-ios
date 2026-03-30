import SwiftUI

struct PersonalRecordsSection: View {
    let records: [PersonalRecord]

    private var topRecords: [PersonalRecord] {
        Array(records.prefix(10))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Personal Records")
                .dripSectionHeader()

            ForEach(Array(topRecords.enumerated()), id: \.element.id) { index, pr in
                PRRow(record: pr, rank: index + 1)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
    }
}

struct PRRow: View {
    let record: PersonalRecord
    let rank: Int

    private var rankIcon: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "🏅"
        }
    }

    var body: some View {
        DripCard(padding: Spacing.md) {
            HStack {
                Text(rankIcon)
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 4) {
                    Text(record.exerciseName)
                        .font(.labelLarge)
                        .foregroundStyle(.textPrimary)
                    HStack(spacing: Spacing.xs) {
                        Text(record.recordType == .maxWeight ? "Max Weight" : "Max Reps")
                            .font(.caption)
                            .foregroundStyle(.textTertiary)
                        Text("·")
                            .foregroundStyle(.textTertiary)
                        Text(record.achievedDate.shortFormatted)
                            .font(.caption)
                            .foregroundStyle(.textTertiary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(record.recordType == .maxWeight
                         ? "\(Int(record.value)) lbs"
                         : "\(Int(record.value)) reps")
                        .font(.titleSmall)
                        .foregroundStyle(.achieveGold)
                        .monospacedDigit()

                    if record.improvement > 0 {
                        Text("+\(String(format: "%.0f", record.improvement))%")
                            .font(.caption)
                            .foregroundStyle(.success)
                    }
                }
            }
        }
    }
}
