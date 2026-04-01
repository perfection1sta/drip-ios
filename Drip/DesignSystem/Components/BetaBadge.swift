import SwiftUI

struct BetaBadge: View {
    var body: some View {
        Text("BETA")
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .foregroundStyle(.achieveGold)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.achieveGold.opacity(0.15), in: Capsule())
            .overlay(Capsule().stroke(Color.achieveGold.opacity(0.35), lineWidth: 1))
    }
}
