import SwiftUI

struct OnboardingProgressBar: View {
    let progress: Double  // 0.0 – 1.0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.surfaceTertiary)
                    .frame(height: 3)

                Capsule()
                    .fill(LinearGradient.energyGradient)
                    .frame(width: geo.size.width * progress, height: 3)
                    .animation(.smooth, value: progress)
            }
        }
        .frame(height: 3)
    }
}
