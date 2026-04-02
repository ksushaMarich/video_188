import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.openURL) private var openURL
    @State private var currentState: OnboardingState = .welcome

    var body: some View {
        ZStack {
            backgroundImage
            content
        }
        .ignoresSafeArea()
    }

    private var content: some View {
        VStack(spacing: 0) {
            Spacer()

//            if currentState == .paywall {
//                OnboardingPaywallView()
//            } else {
                contentPanel
//            }
        }
    }

    @ViewBuilder private var backgroundImage: some View {
        switch currentState {
            case .welcome:
                Image(.onboardingFirst)
                    .resizable()
                    .ignoresSafeArea()
            case .reviews:
                Image(.onboardingSecond)
                    .resizable()
                    .ignoresSafeArea()
            case .features:
                Image(.onboardingThird)
                    .resizable()
                    .ignoresSafeArea()
            case .paywall:
                Image(.paywall)
                    .resizable()
                    .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var contentPanel: some View {
        VStack(spacing: 24) {
            VStack(spacing: 32) {
                infoContainer

                continueButton
            }

            footer
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 34)
    }

    @ViewBuilder
    private var infoContainer: some View {
        VStack(spacing: 8) {
            
            Text(currentState.title)
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
            
            Text(currentState.subtitle)
                .font(CabinetGroteskFont.medium.of(size: 20))
                .foregroundColor(Color.introSubtitle)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    private var continueButton: some View {
        Button {
            nextPage()
        } label: {
            Text("Continue")
                .font(CabinetGroteskFont.bold.of(size: 16))
                .foregroundColor(.textBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.introAccentSecondary)
                )
                .contentShape(RoundedRectangle(cornerRadius: 8))
        }
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
                .font(CabinetGroteskFont.medium.of(size: 14))
                .foregroundColor(.introSubtitle)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
        }
    }

    private func nextPage() {
        let allStates = OnboardingState.allCases
        let currentIndex = allStates.firstIndex(of: currentState) ?? 0

        withAnimation(.easeInOut(duration: 0.3)) {
            currentState = allStates[currentIndex + 1]
        }
    }

    private func restorePurchases() {
        purchaseManager.restorePurchase { success in
            if success {
                purchaseManager.hasSeenOnBoarding = true
            }
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
    OnboardingView()
        .environmentObject(PurchaseManager.shared)
}
