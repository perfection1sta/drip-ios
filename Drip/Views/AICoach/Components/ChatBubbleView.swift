import SwiftUI

struct ChatBubbleView: View {
    let message: AIMessage

    var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.xs) {
            if isUser { Spacer(minLength: 48) }

            if !isUser {
                // Coach avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient.energyGradient)
                        .frame(width: 28, height: 28)
                    Text("💧")
                        .font(.system(size: 14))
                }
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(TypographyTokens.bodyMedium)
                    .foregroundStyle(isUser ? .white : .textPrimary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background {
                        if isUser {
                            RoundedRectangle(cornerRadius: Spacing.Radius.xl)
                                .fill(LinearGradient.energyGradient)
                        } else {
                            RoundedRectangle(cornerRadius: Spacing.Radius.xl)
                                .fill(Color.surfaceSecondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Spacing.Radius.xl)
                                        .stroke(Color.surfaceTertiary, lineWidth: 1)
                                )
                        }
                    }

                Text(message.timestamp, style: .time)
                    .font(TypographyTokens.caption)
                    .foregroundStyle(.textTertiary)
            }

            if !isUser { Spacer(minLength: 48) }
        }
        .padding(.horizontal, Spacing.md)
    }
}
