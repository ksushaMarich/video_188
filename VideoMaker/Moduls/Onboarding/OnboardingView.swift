import SwiftUI
import Lottie

struct OnboardingView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.openURL) private var openURL
    @State private var currentStep: AppIntroStep = .first
    @State private var isLoading = false

    var body: some View {
        if currentStep == .paywall {
            OnboardingPaywallView()
        } else {
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
                    Color.black
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    VStack(spacing: 24) {
                        VStack(spacing: 32) {
                            infoContainer
                            
                            ContinueButton(isDisabled: $isLoading) {
                                let allStates = AppIntroStep.allCases
                                let currentIndex = allStates.firstIndex(of: currentStep) ?? 0
                                
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStep = allStates[currentIndex + 1]
                                }
                            }
                        }
                        
                        TermsPrivacyRestoreFooter {
                            isLoading = true
                            purchaseManager.restorePurchase { success in
                                isLoading = false
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
            .disabled(isLoading)
            .ignoresSafeArea()
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
