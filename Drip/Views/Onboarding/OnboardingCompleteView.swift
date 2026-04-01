import SwiftUI
import SwiftData

struct OnboardingCompleteView: View {
    @Environment(\.modelContext) private var context
    @Environment(OnboardingViewModel.self) private var vm
    @State private var appeared = false
    @State private var showConfetti = false

    var accentColor: Color {
        vm.selectedArchetype?.accentColor ?? .energyOrange
    }

    var body: some View {
        ZStack {
            // Particle burst canvas
            if showConfetti {
                ConfettiBurst(color: accentColor)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            VStack(spacing: 0) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 120, height: 120)
                    Circle()
                        .fill(accentColor.opacity(0.08))
                        .frame(width: 160, height: 160)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(accentColor)
                }
                .scaleEffect(appeared ? 1 : 0.3)
                .opacity(appeared ? 1 : 0)
                .animation(.bouncy.delay(0.1), value: appeared)

                Spacer().frame(height: Spacing.xxl)

                VStack(spacing: Spacing.sm) {
                    Text("You're all set, \(vm.name)!")
                        .font(.displaySmall)
                        .foregroundStyle(.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Your first workout is ready.\nTime to start your streak.")
                        .font(.bodyLarge)
                        .foregroundStyle(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.smooth.delay(0.3), value: appeared)

                Spacer().frame(height: Spacing.xl)

                // Summary chips
                HStack(spacing: Spacing.sm) {
                    SummaryChip(icon: vm.selectedArchetype?.iconName ?? "dumbbell", label: vm.selectedArchetype?.displayName ?? "", color: accentColor)
                    SummaryChip(icon: "clock", label: "\(vm.preferredDurationMinutes) min", color: accentColor)
                    SummaryChip(icon: "flame.fill", label: "\(vm.preferredFrequencyDays)× / week", color: accentColor)
                }
                .opacity(appeared ? 1 : 0)
                .animation(.smooth.delay(0.4), value: appeared)

                Spacer()

                DripButton("Start My Journey", style: .primary) {
                    HapticManager.shared.success()
                    vm.completeOnboarding(context: context)
                }
                .opacity(appeared ? 1 : 0)
                .animation(.smooth.delay(0.5), value: appeared)

                Spacer().frame(height: Spacing.xl)
            }
            .padding(.horizontal, Spacing.lg)
        }
        .onAppear {
            appeared = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                showConfetti = true
                HapticManager.shared.personalRecord()
            }
        }
    }
}

private struct SummaryChip: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(label)
                .font(.labelSmall)
        }
        .foregroundStyle(color)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xxs)
        .background(color.opacity(0.15), in: Capsule())
    }
}

// MARK: - Simple confetti burst using Canvas
private struct ConfettiBurst: View {
    let color: Color
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                for p in particles {
                    let elapsed = now - p.birth
                    guard elapsed < p.lifetime else { continue }
                    let progress = elapsed / p.lifetime
                    let x = p.origin.x + p.velocity.x * elapsed
                    let y = p.origin.y + p.velocity.y * elapsed + 0.5 * 300 * elapsed * elapsed
                    let opacity = 1 - progress
                    ctx.opacity = opacity
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: p.size, height: p.size * 0.6)),
                        with: .color(p.color)
                    )
                }
            }
        }
        .onAppear {
            particles = (0..<60).map { _ in
                ConfettiParticle(
                    origin: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.35),
                    velocity: CGPoint(
                        x: CGFloat.random(in: -200...200),
                        y: CGFloat.random(in: -400 ... -100)
                    ),
                    color: [color, .energyOrange, .achieveGold, .wellnessTeal].randomElement()!,
                    size: CGFloat.random(in: 6...14),
                    lifetime: Double.random(in: 1.0...2.0),
                    birth: Date().timeIntervalSinceReferenceDate
                )
            }
        }
    }
}

private struct ConfettiParticle {
    let origin: CGPoint
    let velocity: CGPoint
    let color: Color
    let size: CGFloat
    let lifetime: Double
    let birth: TimeInterval
}
