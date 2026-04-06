import SwiftUI

struct SegmentedControl: View {
    @Binding var isTrial: Bool

    var body: some View {
        HStack(spacing: 8) {
            segment(
                title: "Free Trial",
                selected: isTrial)
            {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isTrial = true
                }
            }
            
            segment(
                title: "Weekly",
                selected: !isTrial)
            {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isTrial = false
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.segmentedBackground.opacity(0.8)))
    }

    private func segment(
        title: String,
        selected: Bool,
        action: @escaping () -> Void) -> some View
    {
        Button {
            action()
        } label: {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.introSubtitle)
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(
                    Group {
                        if selected {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.introSubtitle.opacity(0.2))
                        }
                    })
                .contentShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
