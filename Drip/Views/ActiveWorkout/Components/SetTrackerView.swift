import SwiftUI

enum SetBubbleState { case pending, active, completed, skipped }

struct SetTrackerView: View {
    let workoutExercise: WorkoutExercise
    let currentSet: Int

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Text("Sets")
                .font(.labelSmall)
                .foregroundStyle(.white.opacity(0.6))

            HStack(spacing: Spacing.md) {
                ForEach(0..<workoutExercise.sets, id: \.self) { index in
                    let state: SetBubbleState = {
                        if index < currentSet  { return .completed }
                        if index == currentSet { return .active }
                        return .pending
                    }()
                    SetBubble(setNumber: index + 1,
                              targetReps: workoutExercise.reps,
                              state: state)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: Spacing.Radius.lg))
    }
}

struct SetBubble: View {
    let setNumber: Int
    let targetReps: Int
    let state: SetBubbleState

    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(bgColor)
                    .frame(width: 52, height: 52)
                    .overlay(
                        Circle()
                            .strokeBorder(borderColor, lineWidth: state == .active ? 2 : 0)
                    )
                    .scaleEffect(state == .active && !reduceMotion ? 1.05 : 1.0)
                    .animation(
                        state == .active ? .bouncy.repeatForever(autoreverses: true) : .snappy,
                        value: state == .active
                    )

                if state == .completed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .scaleEffect(appeared ? 1.0 : 0.3)
                        .animation(.bouncy, value: appeared)
                } else {
                    Text("\(setNumber)")
                        .font(.titleSmall)
                        .foregroundStyle(textColor)
                }
            }
            Text("\(targetReps)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
        .onAppear { if state == .completed { appeared = true } }
        .onChange(of: state) { _, newState in
            if newState == .completed {
                withAnimation(.bouncy) { appeared = true }
            } else {
                appeared = false
            }
        }
    }

    private var bgColor: Color {
        switch state {
        case .pending:   return Color.white.opacity(0.08)
        case .active:    return .wellnessTeal.opacity(0.3)
        case .completed: return .energyOrange
        case .skipped:   return Color.white.opacity(0.1)
        }
    }
    private var borderColor: Color {
        state == .active ? .wellnessTeal : .clear
    }
    private var textColor: Color {
        state == .active ? .wellnessTeal : .white.opacity(0.6)
    }
}
