import SwiftUI

struct SetCompletionOverlay: View {
    let info: String
    @State private var particles: [Particle] = []
    @State private var opacity: Double = 1.0

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var vx: CGFloat
        var vy: CGFloat
        var color: Color
        var scale: CGFloat
        var rotation: Double
    }

    var body: some View {
        ZStack {
            // Particle canvas
            TimelineView(.animation) { timeline in
                Canvas { ctx, size in
                    let elapsed = timeline.date.timeIntervalSinceReferenceDate
                    for p in particles {
                        let t = elapsed.truncatingRemainder(dividingBy: 1.0)
                        let px = p.x + p.vx * t * 100
                        let py = p.y + p.vy * t * 100
                        let alpha = max(0, 1 - t * 1.2)
                        let circle = Path(ellipseIn: CGRect(x: px - 4, y: py - 4, width: 8, height: 8))
                        ctx.fill(circle, with: .color(p.color.opacity(alpha)))
                    }
                }
            }
            .allowsHitTesting(false)

            // Center badge
            VStack(spacing: Spacing.sm) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.energyOrange)
                    .symbolRenderingMode(.hierarchical)

                Text("Set Complete!")
                    .font(.titleMedium)
                    .foregroundStyle(.white)

                Text(info)
                    .font(.bodyMedium)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .opacity(opacity)
        }
        .onAppear {
            generateParticles()
            withAnimation(.smooth.delay(0.8)) { opacity = 0 }
        }
    }

    private func generateParticles() {
        let colors: [Color] = [.energyOrange, .energyRed, .achieveGold, .wellnessTeal, .white]
        particles = (0..<20).map { _ in
            Particle(
                x: UIScreen.main.bounds.width / 2,
                y: UIScreen.main.bounds.height / 2,
                vx: CGFloat.random(in: -2...2),
                vy: CGFloat.random(in: -3...(-0.5)),
                color: colors.randomElement()!,
                scale: CGFloat.random(in: 0.5...1.5),
                rotation: Double.random(in: 0...360)
            )
        }
    }
}

// MARK: - PR Celebration Banner

struct PRCelebrationBanner: View {
    let exerciseName: String

    var body: some View {
        VStack {
            HStack(spacing: Spacing.sm) {
                Text("🏆")
                    .font(.system(size: 24))
                VStack(alignment: .leading, spacing: 2) {
                    Text("New Personal Record!")
                        .font(.titleSmall)
                        .foregroundStyle(.achieveGold)
                    Text(exerciseName)
                        .font(.bodySmall)
                        .foregroundStyle(.white.opacity(0.8))
                }
                Spacer()
            }
            .padding(Spacing.md)
            .background(
                LinearGradient.goldAchieve.opacity(0.3)
                    .background(.ultraThinMaterial)
            )
            .clipShape(RoundedRectangle(cornerRadius: Spacing.Radius.lg))
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.xxxl)

            Spacer()
        }
    }
}
