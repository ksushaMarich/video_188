
import SwiftUI
import StoreKit
import ApphudSDK
import ApphudBase

struct ContentView: View {
    @AppStorage("hasShownReviewAlert") private var hasShownReviewAlert = false
    @AppStorage("isOnboardingFinished") private var isOnboardingFinished = false
    @EnvironmentObject private var purchaseManager: PurchaseManager

    var body: some View {
        Group {
            if isOnboardingFinished {
                Text("Test")
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: purchaseManager.hasSeenOnBoarding)
        .onChange(of: purchaseManager.hasSeenOnBoarding) {
            if purchaseManager.hasSeenOnBoarding && !isOnboardingFinished {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    requestAppStoreReview()
                    isOnboardingFinished = true
                }
            }
        }
    }

    private func requestAppStoreReview() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: windowScene)
    }
}

#Preview {
    ContentView()
}
