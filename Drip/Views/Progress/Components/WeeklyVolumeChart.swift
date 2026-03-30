import SwiftUI
import Charts

struct WeeklyVolumeChart: View {
    let data: [ProgressViewModel.DailyVolume]
    @State private var animateChart = false

    var body: some View {
        DripCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Volume Over Time")
                    .font(.titleSmall)
                    .foregroundStyle(.textPrimary)

                Chart {
                    ForEach(data) { day in
                        BarMark(
                            x: .value("Date", day.date, unit: .day),
                            y: .value("Volume", animateChart ? day.volumeLbs : 0)
                        )
                        .foregroundStyle(
                            day.volumeLbs > 0
                                ? LinearGradient.energyGradient
                                : LinearGradient(colors: [.surfaceTertiary], startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(4)
                    }
                }
                .frame(height: 160)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: data.count > 14 ? 7 : 2)) { value in
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            .foregroundStyle(Color.textTertiary)
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.surfaceTertiary)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .foregroundStyle(Color.textTertiary)
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(Color.surfaceTertiary)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.smooth.delay(0.3)) { animateChart = true }
        }
        .onChange(of: data.count) { _, _ in
            animateChart = false
            withAnimation(.smooth.delay(0.1)) { animateChart = true }
        }
    }
}
