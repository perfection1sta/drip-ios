import SwiftUI

// MARK: - Progress Ring
// Animatable circular arc — used for rest timer and workout completion.

struct ProgressRing: Shape {
    var trimFraction: Double // 0.0 → 1.0

    var animatableData: Double {
        get { trimFraction }
        set { trimFraction = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let start  = Angle.degrees(-90)
        let end    = Angle.degrees(-90 + 360 * trimFraction)

        return Path { p in
            p.addArc(center: center,
                     radius: radius,
                     startAngle: start,
                     endAngle: end,
                     clockwise: false)
        }
    }
}

// MARK: - Ring Container View
struct ProgressRingView: View {
    let progress: Double     // 0.0 – 1.0
    let ringWidth: CGFloat
    let size: CGFloat
    let foreground: Color
    var showPercent: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: ringWidth)

            // Fill
            ProgressRing(trimFraction: progress)
                .stroke(
                    foreground,
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                .animation(reduceMotion ? nil : .smooth, value: progress)

            if showPercent {
                Text("\(Int(progress * 100))%")
                    .font(.labelLarge)
                    .foregroundStyle(.textSecondary)
            }
        }
        .frame(width: size, height: size)
    }
}
