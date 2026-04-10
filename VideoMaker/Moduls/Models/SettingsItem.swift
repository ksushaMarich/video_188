import SwiftUI

enum SettingsItem: CaseIterable {
    case privacyPolicy
    case termsOfUse
    case shareApp
    case support

    var title: String {
        switch self {
            case .privacyPolicy:
                return "Privacy Policy"
            case .termsOfUse:
                return "Terms of Use"
            case .shareApp:
                return "Share app"
            case .support:
                return "Support"
        }
    }
}
