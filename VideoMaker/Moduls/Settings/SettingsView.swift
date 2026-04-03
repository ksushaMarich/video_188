import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var purchaseManager: PurchaseManager

    var body: some View {
        Color.mainBackground
            .overlay(alignment: .top) {
                VStack(spacing: 24) {
                    premiumCard
                    content
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
    }

    private var content: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Button {
                    viewModel.handleItemTap(SettingsItem.support)
                } label: {
                    Text(SettingsItem.support.title)
                        .font(CabinetGroteskFont.bold.of(size: 16))
                        .foregroundColor(.mainBackground)
                        .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.introAccentSecondary)
                )
                Button {
                    viewModel.handleItemTap(SettingsItem.shareApp)
                } label: {
                    Text(SettingsItem.shareApp.title)
                        .font(CabinetGroteskFont.bold.of(size: 16))
                        .foregroundColor(.introSubtitle)
                        .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.introAccentSecondary.opacity(0.2))
                )
            }

            HStack(spacing: 0) {
                Button {
                    viewModel.handleItemTap(SettingsItem.termsOfUse)
                } label: {
                    Text(SettingsItem.termsOfUse.title)
                        .foregroundColor(Color.introSubtitle)
                        .font(CabinetGroteskFont.medium.of(size: 14))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    viewModel.handleItemTap(SettingsItem.privacyPolicy)
                } label: {
                    Text(SettingsItem.privacyPolicy.title)
                        .foregroundColor(Color.introSubtitle)
                        .font(CabinetGroteskFont.medium.of(size: 14))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
        }
    }

    @ViewBuilder
    private var premiumCard: some View {
        if !purchaseManager.isSubscribed {
            Button {
                purchaseManager.isShowedPaywall = true
            } label: {
                Image(.getPremiumBunner)
                    .resizable()
                    .scaledToFit()
                    .contentShape(Rectangle())
            }
        } else {
            Image(.premiumBanner)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(PurchaseManager.shared)
}
