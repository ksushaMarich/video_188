//
//  ContentView.swift
//  VideoMaker
//
//  Created by Ксения Маричева on 01.04.2026.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    @AppStorage("reviewAlertShown") private var reviewAlertShown = false
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false

    @EnvironmentObject private var purchaseManager: PurchaseManager

    var body: some View {
        Group {
            OnboardingView()

        }
//        .animation(.easeInOut(duration: 0.3), value: purchaseManager.hasSeenOnBoarding)
//        .fullScreenCover(isPresented: $purchaseManager.isShowedPaywall) {
//            PaywallView(isTrialEnabled: false, product: purchaseManager.nonTrialProduct)
//        }
//        .onChange(of: purchaseManager.isOnboardingFinished) { newValue in
//            if newValue && !onboardingCompleted {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                    requestAppStoreReview()
//                    onboardingCompleted = true
//                }
//            }
//        }
    }

    private func requestAppStoreReview() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: windowScene)
    }
}

#Preview {
    ContentView()
}
