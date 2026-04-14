import AdServices
import ApphudSDK
import ApphudBase
import SwiftUI
import Combine

@MainActor
final class PurchaseManager: ObservableObject {
    @AppStorage("hasSeenOnBoarding") var hasSeenOnBoarding = false
    @Published private(set) var paywall: ApphudPaywall!

    @Published private(set) var trialProduct: ApphudProduct!
    @Published private(set) var nonTrialProduct: ApphudProduct!
    @Published private(set) var lifetimeProduct: ApphudProduct!
    @Published private(set) var isSubscribed = false
    @Published private(set) var products: [ApphudProduct]!
    @Published var isShowedPaywall = false

    static let shared = PurchaseManager()

    private init() {
        Apphud.configure(apiKey: AppConfig.apphudToken)

        Task {
            let paywall = await Apphud.fetchPaywallWithFallback(paywallID: "paywall")!
            self.configure(with: paywall)
        }
        #if DEBUG
            isSubscribed = false
        #else
            isSubscribed = Apphud.hasPremiumAccess()
        #endif
        isShowedPaywall = !isSubscribed && hasSeenOnBoarding
        print(isShowedPaywall)
    }

    private func configure(with paywall: ApphudPaywall) {
        self.paywall = paywall
        nonTrialProduct = paywall.products.first(where: { !$0.isTrial })
        trialProduct = paywall.products.first(where: { $0.isTrial })
        lifetimeProduct = paywall.products.first(where: { $0.isLifetime })
        products = paywall.products
    }
    
    func makePurchase(product: ApphudProduct, completion: @escaping (Bool) -> Void) {
        Task { @MainActor in
            let result = await Apphud.fallbackPurchase(product: product)
            self.isSubscribed = result
            completion(result)
        }
    }

    func restorePurchase(completion: @escaping (Bool) -> Void) {
        Task { @MainActor in
            let result = await Apphud.fallbackRestore()
            self.isSubscribed = result
            completion(result)
            return
        }
    }
}
