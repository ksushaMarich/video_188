import SwiftUI

enum TabItem: CaseIterable {
    case main
    case lab
    case settings

    var icon: ImageResource {
        switch self {
            case .main:
                return .mainTabIcon
            case .lab:
                return .labTabIcon
            case .settings:
                return .settingsTabIcon
        }
    }
}
