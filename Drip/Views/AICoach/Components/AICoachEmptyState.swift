import SwiftUI

struct AICoachEmptyState: View {
    let starterPrompts: [String]
    let onPromptTapped: (String) -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            VStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(LinearGradient.energyGradient)
                        .frame(width: 72, height: 72)
                        .shadow(color: .energyOrange.opacity(0.4), radius: 20, y: 6)
                    Text("💧")
                        .font(.system(size: 36))
                }
                .scaleEffect(appeared ? 1 : 0.5)
                .opacity(appeared ? 1 : 0)
                .animation(.bouncy.delay(0.1), value: appeared)

                VStack(spacing: Spacing.xs) {
                    Text("Meet Drip Coach")
                        .font(TypographyTokens.titleLarge)
                        .foregroundStyle(.textPrimary)
                    Text("Your AI-powered fitness coach.\nAsk anything about your training.")
                        .font(TypographyTokens.bodyMedium)
                        .foregroundStyle(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.smooth.delay(0.2), value: appeared)
            }

            Spacer()

            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Try asking...")
                    .font(TypographyTokens.labelLarge)
                    .foregroundStyle(.textSecondary)
                    .padding(.horizontal, Spacing.lg)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.xs) {
                        ForEach(Array(starterPrompts.enumerated()), id: \.offset) { index, prompt in
                            Button {
                                HapticManager.shared.selection()
                                onPromptTapped(prompt)
                            } label: {
                                HStack {
                                    Text(prompt)
                                        .font(TypographyTokens.bodyMedium)
                                        .foregroundStyle(.textPrimary)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    Image(systemName: "arrow.up.circle.fill")
                                        .foregroundStyle(.energyOrange)
                                        .font(.system(size: 20))
                                }
                                .padding(Spacing.md)
                                .background(Color.surfaceSecondary, in: RoundedRectangle(cornerRadius: Spacing.Radius.lg))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Spacing.Radius.lg)
                                        .stroke(Color.surfaceTertiary, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(.smooth.delay(0.3 + Double(index) * 0.06), value: appeared)
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                }
            }

            Spacer().frame(height: Spacing.xxl)
        }
        .onAppear { appeared = true }
    }
}
