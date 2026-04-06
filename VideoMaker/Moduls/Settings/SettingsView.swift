import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var purchaseManager: PurchaseManager

    var body: some View {
        VStack(spacing: 24) {
            premiumCard
            content
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            Color.mainBackground
                .ignoresSafeArea()
        )
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
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.introAccentSecondary)
                            )
                        .contentShape(RoundedRectangle(cornerRadius: 8))
                }
                Button {
                    viewModel.handleItemTap(SettingsItem.shareApp)
                } label: {
                    Text(SettingsItem.shareApp.title)
                        .font(CabinetGroteskFont.bold.of(size: 16))
                        .foregroundColor(.introSubtitle)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.introAccentSecondary.opacity(0.2))
                            )
                        .contentShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            HStack(spacing: 0) {
                Button {
                    viewModel.handleItemTap(SettingsItem.termsOfUse)
                } label: {
                    Text(SettingsItem.termsOfUse.title)
                        .foregroundColor(Color.introSubtitle)
                        .font(CabinetGroteskFont.medium.of(size: 14))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .multilineTextAlignment(.center)
                        .contentShape(Rectangle())
                }
                
                Button {
                    viewModel.handleItemTap(SettingsItem.privacyPolicy)
                } label: {
                    Text(SettingsItem.privacyPolicy.title)
                        .foregroundColor(Color.introSubtitle)
                        .font(CabinetGroteskFont.medium.of(size: 14))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .multilineTextAlignment(.center)
                        .contentShape(Rectangle())
                }
            }
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
