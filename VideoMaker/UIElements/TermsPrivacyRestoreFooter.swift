
import SwiftUI

struct TermsPrivacyRestoreFooter: View {
    @Environment(\.openURL) private var openURL
    var onRestore: () -> Void

    var body: some View {
        HStack {
            footerLink("Terms of Use", action: { openURL(string: AppConfig.Links.termsOfUse) })
            Spacer()
            footerLink("Restore", action: onRestore)
            Spacer()
            footerLink("Privacy Policy", action: { openURL(string: AppConfig.Links.privacyPolicy) })
        }
    }

    @ViewBuilder
    private func footerLink(_ text: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(text)
                .font(CabinetGroteskFont.medium.of(size: 14))
                .foregroundColor(.introSubtitle)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
        }
    }
    
    private func openURL(string: String) {
        guard let url = URL(string: string) else { return }
        openURL(url)
    }
}

