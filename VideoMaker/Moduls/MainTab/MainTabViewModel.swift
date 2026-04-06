import Foundation
import Combine

final class MainTabViewModel: ObservableObject {
    
    @Published var selectedTab: TabItem = .main
    @Published var isTabBarHidden = false

    func selectTab(_ tab: TabItem) {
        selectedTab = tab
    }
}
