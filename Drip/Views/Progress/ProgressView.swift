import SwiftUI
import Charts

struct ProgressView: View {
    @Environment(ProgressViewModel.self) private var vm
    @Environment(\.modelContext) private var context
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.darkSurface.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Summary pills
                        summaryRow
                            .opacity(appeared ? 1 : 0)
                            .animation(.staggered(0), value: appeared)

                        // Time range picker
                        timeRangePicker
                            .opacity(appeared ? 1 : 0)
                            .animation(.staggered(1), value: appeared)

                        // Volume chart
                        WeeklyVolumeChart(data: vm.weeklyVolume)
                            .opacity(appeared ? 1 : 0)
                            .animation(.staggered(2), value: appeared)

                        // Streak calendar
                        StreakCalendarView(days: vm.calendarDays)
                            .opacity(appeared ? 1 : 0)
                            .animation(.staggered(3), value: appeared)

                        // Personal records
                        if !vm.personalRecords.isEmpty {
                            PersonalRecordsSection(records: vm.personalRecords)
                                .opacity(appeared ? 1 : 0)
                                .animation(.staggered(4), value: appeared)
                        }

                        // Session history
                        if !vm.sessionHistory.isEmpty {
                            sessionHistory
                                .opacity(appeared ? 1 : 0)
                                .animation(.staggered(5), value: appeared)
                        }

                        Spacer(minLength: Spacing.huge)
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            vm.load(context: context)
            withAnimation { appeared = true }
        }
    }

    private var summaryRow: some View {
        HStack(spacing: Spacing.sm) {
            StatPill(label: "Workouts",
                     value: "\(vm.totalWorkouts)",
                     unit: "total",
                     accentColor: .energyOrange)
            StatPill(label: "Volume",
                     value: vm.totalVolumeLbs > 1000
                         ? "\(Int(vm.totalVolumeLbs / 1000))K"
                         : "\(Int(vm.totalVolumeLbs))",
                     unit: "lbs lifted",
                     accentColor: .wellnessTeal)
            StatPill(label: "Avg Session",
                     value: "\(Int(vm.avgSessionMinutes))",
                     unit: "minutes",
                     accentColor: .achieveGold)
        }
    }

    @Bindable var bindableVM: ProgressViewModel = ProgressViewModel()

    private var timeRangePicker: some View {
        @Bindable var bvm = vm
        return Picker("Range", selection: $bvm.selectedTimeRange) {
            ForEach(ProgressViewModel.TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: vm.selectedTimeRange) { _, range in
            vm.load(context: context, range: range)
        }
    }

    private var sessionHistory: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Recent Sessions")
                .dripSectionHeader()
            ForEach(vm.sessionHistory) { session in
                RecentActivityRow(session: session)
            }
        }
    }
}
