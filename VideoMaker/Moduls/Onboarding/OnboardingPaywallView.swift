import ApphudSDK
import SwiftUI
import Lottie
import ApphudBase

struct OnboardingPaywallView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.openURL) private var openURL
    @State private var isTrialEnabled = false
    @State private var isLoading = false
    
    var prod: ApphudProduct {
        let prod = isTrialEnabled ? purchaseManager.trialProduct : purchaseManager.nonTrialProduct
        return prod!
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            contentPanel
        }
        .disabled(isLoading)
        .ignoresSafeArea()
        .background {
            backgroundImage
        }
        .onAppear {
            Apphud.paywallShown(prod)
        }
        .onDisappear {
            Apphud.paywallClosed(prod)
        }
        .overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                    
                    LottieView(animationName: "bolt", loopMode: .loop)
                        .frame(width: 100, height: 100)
                }
            }
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
            VStack(alignment: .center, spacing: 20) {
                VStack(spacing: 16) {
                    Text("Full Power With\nPremium Features")
                        .font(CabinetGroteskFont.extrabold.of(size: 40))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.introAccentSecondary,
                                    Color.introAccentPrimary
                                ],
                                startPoint: .bottomLeading,
                                endPoint: .topTrailing
                            )
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        
                    Text("Share, download, and create more\n with a premium subscription")
                        .font(CabinetGroteskFont.medium.of(size: 20))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.introSubtitle)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    SegmentedControl(isTrial: $isTrialEnabled)
                }

                VStack(spacing: 24) {
                    subscriptionText()
                    
                    ContinueButton(isDisabled: $isLoading) {
                        startPurchase()
                    }
                }
            }

            TermsPrivacyRestoreFooter {
                isLoading = true

                purchaseManager.restorePurchase { success in
                    isLoading = false
                    purchaseManager.hasSeenOnBoarding = success
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 34)
    }



    @ViewBuilder
    private func subscriptionText() -> some View {
        let price = isTrialEnabled
            ? purchaseManager.trialProduct.fullPrice
            : purchaseManager.nonTrialProduct.fullPrice

        VStack(spacing: 0) {
            Text(isTrialEnabled ? "Subscribe to unlock all the features\nfor just \(price)" : "Subscribe to unlock all the\nfeatures for just \(price)")
                .foregroundColor(.introSubtitle)
                .font(CabinetGroteskFont.regular.of(size: 17))

            Button {
                purchaseManager.hasSeenOnBoarding = true
            } label: {
                Text("or proceed with limits")
                    .foregroundColor(.introSubtitle)
                    .font(CabinetGroteskFont.regular.of(size: 17))
                    .contentShape(Rectangle())
            }
            .disabled(isLoading)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
    }


    private func startPurchase() {
        isLoading = true
        purchaseManager.makePurchase(
            product: isTrialEnabled
                ? purchaseManager.trialProduct
                : purchaseManager.nonTrialProduct)
        { success in
            isLoading = false
            purchaseManager.hasSeenOnBoarding = success
        }
    }
}

#Preview {
    OnboardingPaywallView()
        .environmentObject(PurchaseManager.shared)
}
