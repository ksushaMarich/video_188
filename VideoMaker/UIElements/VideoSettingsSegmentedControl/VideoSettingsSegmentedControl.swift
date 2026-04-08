
import SwiftUI

struct VideoSettingsSegmentedControl<T>: View where T: CaseIterable & Identifiable & Hashable {
    
    @Binding var selection: T
    var title: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                Text(title)
                    .font(CabinetGroteskFont.bold.of(size: 15))
                    .foregroundColor(.introSubtitle)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)
            HStack(spacing: 8) {
                ForEach(Array(T.allCases), id: \.id) { item in
                    segment(
                        title: title(for: item),
                        selected: item == selection
                    ) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selection = item
                        }
                    }
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.segmentedBackground.opacity(0.8))
        )
    }

    private func segment(
        title: String,
        selected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(CabinetGroteskFont.medium.of(size: 15))
                .foregroundColor(.introSubtitle)
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(
                    Group {
                        if selected {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.introSubtitle.opacity(0.2))
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }

    private func title(for item: T) -> String {
        if let item = item as? Quality {
            return item.resolution
        } else if let item = item as? Duration {
            return item.durationCard
        }
        return "\(item)"
    }
}
