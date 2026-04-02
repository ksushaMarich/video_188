import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.openURL) private var openURL
    @State private var currentStep: AppIntroStep = .first

    var body: some View {
        ZStack {
            switch currentStep {
                case .first:
                    Image(.onboardingFirst)
                        .resizable()
                        .ignoresSafeArea()
                case .second:
                    Image(.onboardingSecond)
                        .resizable()
                        .ignoresSafeArea()
                case .third:
                    Image(.onboardingThird)
                        .resizable()
                        .ignoresSafeArea()
                case .paywall:
                    Image(.paywall)
                        .resizable()
                        .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                Spacer()

                if currentStep == .paywall {
                    OnboardingPaywallView()
                } else {
                    VStack(spacing: 24) {
                        VStack(spacing: 32) {
                            infoContainer
                            
                            ContinueButton {
                                let allStates = AppIntroStep.allCases
                                let currentIndex = allStates.firstIndex(of: currentStep) ?? 0
                                
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStep = allStates[currentIndex + 1]
                                }
                            }
                        }
                        
                        TermsPrivacyRestoreFooter{
                            purchaseManager.restorePurchase { success in
                                if success {
                                    purchaseManager.hasSeenOnBoarding = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                }
            }
        }
        .ignoresSafeArea()
    }

    
    @ViewBuilder
    private var infoContainer: some View {
        VStack(spacing: 8) {
            
            Text(currentStep.title)
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
            
            Text(currentStep.subtitle)
                .font(CabinetGroteskFont.medium.of(size: 20))
                .foregroundColor(Color.introSubtitle)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(PurchaseManager.shared)
}
