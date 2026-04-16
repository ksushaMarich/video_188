import Foundation
import Combine

final class MainTabViewModel: ObservableObject {
    
    @Published var selectedTab: TabItem = .lab
    @Published var isTabBarHidden = false

    func selectTab(_ tab: TabItem) {
        selectedTab = tab
    }
}
