import SwiftUI

struct WorkoutProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 4)

                // Fill
                Capsule()
                    .fill(LinearGradient.energyGradient)
                    .frame(width: max(0, geo.size.width * progress), height: 4)
                    .animation(.smooth, value: progress)
            }
        }
        .frame(height: 4)
        .padding(.horizontal, Spacing.md)
    }
}
