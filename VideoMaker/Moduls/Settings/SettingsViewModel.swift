import SwiftUI
import Combine

final class SettingsViewModel: ObservableObject {
    func handleItemTap(_ item: SettingsItem) {
        switch item {
        case .privacyPolicy:
            openURL(string: AppConfig.Links.privacyPolicy)
        case .termsOfUse:
            openURL(string: AppConfig.Links.termsOfUse)
        case .shareApp:
            shareApp()
        case .support:
            openURL(string: AppConfig.Links.supportForm)
        }
    }
    
    private func openURL(string: String) {
        guard let url = URL(string: string) else { return }
        UIApplication.shared.open(url)
    }

    private func shareApp() {
        guard let url = URL(string: AppConfig.Links.shareApp) else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        UIApplication.shared.topViewController?.present(activityVC, animated: true)
    }
}
