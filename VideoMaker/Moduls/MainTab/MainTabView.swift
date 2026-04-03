import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = MainTabViewModel()

    var body: some View {
        NavigationStack {
            Color.mainBackground
                .ignoresSafeArea()
                .overlay(alignment: .top) {
                    tabContent(for: viewModel.selectedTab)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .environmentObject(viewModel)
                }
                .overlay(alignment: .bottom) {
                    if !viewModel.isTabBarHidden {
                        TabBar(selectedTab: $viewModel.selectedTab)
                    }
                }
        }
    }

    @ViewBuilder
    private func tabContent(for tab: TabItem) -> some View {
        switch tab {
        case .main:
            Text("Home")
        case .lab:
            LabView()
                .environmentObject(viewModel)
        case .settings:
            SettingsView()
        }
    }
}

struct TabBar: View {
    @Binding var selectedTab: TabItem

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(TabItem.allCases.enumerated()), id: \.element) { index, tab in
                
                TabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab
                )
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }

                if index < TabItem.allCases.count - 1 {
                    Image(.tabSeparatorIcon)
                        .resizable()
                        .frame(width: 2, height: 20)
                }
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }
}

struct TabBarItem: View {
    let tab: TabItem
    let isSelected: Bool

    var body: some View {
        Image(tab.icon)
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: 32, height: 32)
            .foregroundStyle(isSelected ? .introSubtitle : .introSubtitle.opacity(0.2))
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    MainTabView()
        .environmentObject(PurchaseManager.shared)
}
