import SwiftUI

struct ProfileHeaderView: View {
    let profile: UserProfile?
    @State private var editingName = false
    @State private var nameInput = ""

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient.energyGradient)
                    .frame(width: 60, height: 60)
                Text(String(profile?.name.prefix(1) ?? "A").uppercased())
                    .font(.titleLarge)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(profile?.name ?? "Athlete")
                    .font(.titleMedium)
                    .foregroundStyle(.textPrimary)
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text("Member since \(profile?.joinDate.shortFormatted ?? "Today")")
                        .font(.caption)
                }
                .foregroundStyle(.textTertiary)
            }

            Spacer()

            VStack(spacing: 4) {
                Text("\(profile?.totalWorkoutsCompleted ?? 0)")
                    .font(.titleMedium)
                    .foregroundStyle(.energyOrange)
                    .monospacedDigit()
                Text("workouts")
                    .font(.caption)
                    .foregroundStyle(.textTertiary)
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}
