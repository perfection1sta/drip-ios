import SwiftUI

struct AITypingIndicator: View {
    @State private var phase = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.xs) {
            ZStack {
                Circle()
                    .fill(LinearGradient.energyGradient)
                    .frame(width: 28, height: 28)
                Text("💧")
                    .font(.system(size: 14))
            }

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color.textSecondary)
                        .frame(width: 7, height: 7)
                        .scaleEffect(phase == i ? 1.4 : 0.8)
                        .animation(.bouncy.repeatForever().delay(Double(i) * 0.2), value: phase)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.surfaceSecondary, in: RoundedRectangle(cornerRadius: Spacing.Radius.xl))

            Spacer(minLength: 48)
        }
        .padding(.horizontal, Spacing.md)
        .onAppear {
            withAnimation { phase = 1 }
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { t in
                phase = (phase + 1) % 3
            }
        }
    }
}
