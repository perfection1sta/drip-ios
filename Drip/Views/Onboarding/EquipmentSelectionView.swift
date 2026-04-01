import SwiftUI

struct EquipmentSelectionView: View {
    @Environment(OnboardingViewModel.self) private var vm
    @State private var appeared = false

    var accentColor: Color {
        vm.selectedArchetype?.accentColor ?? .energyOrange
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: Spacing.xxl)

            VStack(spacing: Spacing.xs) {
                Text(OnboardingStep.equipment.headline)
                    .font(.displaySmall)
                    .foregroundStyle(.textPrimary)
                    .multilineTextAlignment(.center)
                Text("Select everything available to you.")
                    .font(.bodyMedium)
                    .foregroundStyle(.textSecondary)
            }
            .opacity(appeared ? 1 : 0)
            .animation(.smooth.delay(0.05), value: appeared)

            Spacer().frame(height: Spacing.xl)

            // Wrap layout for chips
            ScrollView {
                FlowLayout(spacing: Spacing.xs) {
                    ForEach(vm.relevantEquipment) { equipment in
                        SelectionChip(
                            label: equipment.displayName,
                            iconName: equipment.iconName,
                            isSelected: vm.selectedEquipment.contains(equipment),
                            accentColor: accentColor
                        ) {
                            if vm.selectedEquipment.contains(equipment) {
                                vm.selectedEquipment.remove(equipment)
                            } else {
                                vm.selectedEquipment.insert(equipment)
                            }
                        }
                    }
                }
                .padding(.bottom, Spacing.xl)
            }
            .opacity(appeared ? 1 : 0)
            .animation(.smooth.delay(0.15), value: appeared)

            DripButton("Continue", style: .primary) {
                vm.advance()
            }
            .disabled(!vm.canAdvance)

            Spacer().frame(height: Spacing.xl)
        }
        .padding(.horizontal, Spacing.lg)
        .onAppear { appeared = true }
    }
}

// MARK: - FlowLayout (wrapping HStack)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > width, rowWidth > 0 {
                height += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
