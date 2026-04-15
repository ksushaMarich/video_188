
import SwiftUI

struct TabBar: View {
    @Binding var selectedTab: TabItem

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(TabItem.allCases.enumerated()), id: \.element) { index, tab in
                tabBarItem (
                    tab: tab,
                    isSelected: selectedTab == tab) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }
                .frame(maxWidth: .infinity)

                if index < TabItem.allCases.count - 1 {
                    Image(.tabSeparatorIcon)
                        .resizable()
                        .frame(width: 2, height: 20)
                }
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(content: {
            BlurView(effect: .dark, intensity: 0.24)
                .ignoresSafeArea()
                .background(.mainBackground.opacity(0.8))
        })
    }
    
    @ViewBuilder
    private func tabBarItem(
        tab: TabItem,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(tab.icon)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 32, height: 32)
                .foregroundStyle(
                    isSelected
                    ? .introSubtitle
                    : .introSubtitle.opacity(0.2)
                )
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
