import ApphudSDK
import SwiftUI
import Lottie

struct OnboardingPaywallView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.openURL) private var openURL
    @State private var isTrialEnabled = false
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            contentPanel
        }
        .disabled(isLoading)
        .background {
            Color.bgPrimary
                .ignoresSafeArea()
                .overlay(backgroundImage)
        }
        .onAppear {
            Apphud.paywallShown(purchaseManager.paywall)
        }
        .onDisappear {
            Apphud.paywallClosed(purchaseManager.paywall)
        }
    }

    @ViewBuilder private var backgroundImage: some View {
        Image(.paywall)
            .resizable()
            .ignoresSafeArea()
    }

    @ViewBuilder
    private var contentPanel: some View {
        VStack(alignment: .center, spacing: 24) {
            VStack(alignment: .center, spacing: 45) {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        HStack(spacing: 0) {
                            Text("Unlock")
                                .foregroundColor(.textPrimary)

                            Text(" Full Access")
                                .foregroundColor(.accentPrimary)
                        }
                        .font(CustomTextStyle.titleFirstStyle.font)
                        .fixedSize(horizontal: false, vertical: true)

                        TrialSegmentedControl(isTrial: $isTrialEnabled)
                    }

                    features
                }

                VStack(spacing: 24) {
                    subscriptionText()

                    if isLoading {
                        LottieView(filename: "loader", loopMode: .loop)
                            .frame(width: 48, height: 48)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.accentPrimary))
                    } else {
                        purchaseButton
                    }
                }
            }

            footer
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 34)
    }

    private var features: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                Image(.featureImg)
                    .standardImageStyle(isIcon: false, width: 28, height: 28)
                VStack(spacing: 0) {
                    Text("Generations Access")
                        .font(CustomTextStyle.headlineStyle.font)
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Generate as many videos as you want without any weekly limits")
                        .font(CustomTextStyle.bodyStyle.font)
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }

            HStack(alignment: .top, spacing: 16) {
                Image(.featureImg)
                    .standardImageStyle(isIcon: false, width: 28, height: 28)
                VStack(spacing: 0) {
                    Text("No Watermark")
                        .font(CustomTextStyle.headlineStyle.font)
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("All your videos are clean, with no app logo")
                        .font(CustomTextStyle.bodyStyle.font)
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }

            HStack(alignment: .top, spacing: 16) {
                Image(.featureImg)
                    .standardImageStyle(isIcon: false, width: 28, height: 28)
                VStack(spacing: 0) {
                    Text("Download & Share")
                        .font(CustomTextStyle.headlineStyle.font)
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Save your creations locally and share them anywhere")
                        .font(CustomTextStyle.bodyStyle.font)
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }

    @ViewBuilder
    private func subscriptionText() -> some View {
        let price = isTrialEnabled
            ? purchaseManager.trialProduct.fullPrice
            : purchaseManager.nonTrialProduct.fullPrice

        VStack(alignment: .leading, spacing: 4) {
            Text("Subscribe to unlock all the features\nfor just \(price)")
                .font(CustomTextStyle.bodyStyle.font)
                .foregroundColor(.textPrimary)

            Button {
                purchaseManager.isOnboardingFinished = true
            } label: {
                Text("or proceed with limits")
                    .font(CustomTextStyle.bodyStyle.font)
                    .foregroundColor(.textSecondary)
                    .contentShape(Rectangle())
            }
            .disabled(isLoading)
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var purchaseButton: some View {
        Button {
            startPurchase()
        } label: {
            Text("Continue")
                .font(CustomTextStyle.buttonStyle.font)
                .foregroundColor(.textBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.accentPrimary)
                        .shadow(color: .strokeGreen, radius: 0, x: 0, y: 4))
                .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(isLoading)
    }

    private var footer: some View {
        HStack {
            footerLink("Terms of Use") {
                openTermsOfUse()
            }
            Spacer()
            footerLink("Restore") {
                restorePurchases()
            }
            Spacer()
            footerLink("Privacy Policy") {
                openPrivacyPolicy()
            }
        }
    }

    @ViewBuilder
    private func footerLink(_ text: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(text)
                .font(CustomTextStyle.captionFirstStyle.font)
                .foregroundColor(.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
        }
    }

    private func startPurchase() {
        isLoading = true

        purchaseManager.makePurchase(
            product: isTrialEnabled
                ? purchaseManager.trialProduct
                : purchaseManager.nonTrialProduct)
        { success in
            isLoading = false
            purchaseManager.isOnboardingFinished = success
        }
    }

    private func restorePurchases() {
        isLoading = true

        purchaseManager.restorePurchase { success in
            isLoading = false
            purchaseManager.isOnboardingFinished = success
        }
    }

    private func openTermsOfUse() {
        guard let url =
            URL(
                string: AppConfig.Links.termsOfUse)
        else { return }
        openURL(url)
    }

    private func openPrivacyPolicy() {
        guard let url =
            URL(
                string: AppConfig.Links.privacyPolicy)
        else { return }
        openURL(url)
    }
}

#Preview {
    OnboardingPaywallView()
        .environmentObject(PurchaseManager.shared)
}
