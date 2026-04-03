
import SwiftUI
import StoreKit
import ApphudSDK
import ApphudBase

struct ContentView: View {
    @AppStorage("hasShownReviewAlert") private var hasShownReviewAlert = false
    @EnvironmentObject private var purchaseManager: PurchaseManager

    var body: some View {
        Group {
            if purchaseManager.hasSeenOnBoarding {
                Text("Test")
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: purchaseManager.hasSeenOnBoarding)
        .onChange(of: purchaseManager.hasSeenOnBoarding) { oldValue, newValue in
            if newValue {
                requestAppStoreReview()
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
