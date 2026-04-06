import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = MainTabViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                tabContent(for: viewModel.selectedTab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .environmentObject(viewModel)
                if !viewModel.isTabBarHidden {
                    VStack {
                        Spacer()
                        TabBar(selectedTab: $viewModel.selectedTab)
                    }
                }
            }
            .background(
                Color.mainBackground
                    .ignoresSafeArea()
            )
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

#Preview {
    MainTabView()
        .environmentObject(PurchaseManager.shared)
}
