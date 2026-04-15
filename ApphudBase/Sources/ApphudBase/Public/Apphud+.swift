import Foundation
@_exported import ApphudSDK

extension Apphud {
    private static var allPaywalls: [ApphudPaywall] = []
    private static var openedPaywallIdentifiers: Set<String> = []
	private static var remotePaywalls: [ApphudPaywall] = []
	private static var apphudDelegate: BaseApphudDelegate!
	private static var paywallFetchTask: Task<[ApphudPaywall], Never>?
    
    @MainActor
    public static func configure(apiKey: String, cacheTimeout: TimeInterval = 3600) {
		apphudDelegate = BaseApphudDelegate(
			onPaywallsDidFullyLoad: { paywalls in
				if !paywalls.isEmpty {
					remotePaywalls = paywalls
				}
			}
		)
        Apphud.setPaywallsCacheTimeout(cacheTimeout)
        Apphud.start(apiKey: apiKey)
		Apphud.setDelegate(apphudDelegate)
        
        setAttribution()
        performIntegrityCheck()
    }
    
    @MainActor
    public static func fetchPaywallWithFallback(paywallID: String) async -> ApphudPaywall? {
        let paywalls = await fetchedPaywallsWithFallback()
        return paywalls.first(where: { $0.identifier == paywallID })
    }
    
    @MainActor
    public static func fetchPaywallWithFallback<ApphudJSONContent: Decodable>(paywallID: String) async ->  (ApphudJSONContent, ApphudPaywall)? {
        let paywalls = await fetchedPaywallsWithFallback()
        
        for paywall in paywalls {
            guard paywall.identifier == paywallID, let json = paywall.json else { continue }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: json, options: [])
                let model = try JSONDecoder().decode(ApphudJSONContent.self, from: data)
                return (model, paywall)
            } catch {
                continue
            }
        }
        
        return nil
    }
    
    @MainActor
    private static func fetchedPaywallsWithFallback() async -> [ApphudPaywall] {
		if let paywallFetchTask {
			return await paywallFetchTask.value
		}
		#if DEBUG
		let startDate = Date()
		defer {
			let endDate = Date()
			debugPrint("Fetch remote paywalls finished in \(endDate.timeIntervalSince(startDate))")
		}
		#endif
		
		let task = Task<[ApphudPaywall], Never> { @MainActor in
			let remote = Task(timeout: 5.0) { @MainActor in
				await withCheckedContinuation { continuation in
					Apphud.paywallsDidLoadCallback { paywalls, _ in
						continuation.resume(returning: paywalls)
					}
				}
			}
			
			do {
				let result = try await remote.result.get()
				if !result.isEmpty {
					remotePaywalls = result
				}
			} catch {
				debugPrint(error.localizedDescription)
			}
			
			allPaywalls = remotePaywalls + fallbackPaywalls
			
			return allPaywalls
		}
		
		paywallFetchTask = task
        
		return await task.value
    }
    
    @MainActor
    public static func fallbackPurchase(product: ApphudProduct) async -> Bool {
        if let paywallIdentifier = product.paywallIdentifier {
            assert(openedPaywallIdentifiers.contains(paywallIdentifier), "[ApphudBase] Paywall not shown: \(paywallIdentifier)")
        } else {
            assertionFailure("[ApphudBase] Product has no paywallIdentifier")
        }
		var product = product
		if
			let remotePaywall = remotePaywalls.first(where: { $0.identifier == product.paywallIdentifier }),
			let remoteProduct = remotePaywall.products.first(where: { $0.productId == product.productId }) {
			product = remoteProduct
		}
        let success: Bool
        if (Apphud.isSandbox() || product.skProduct == nil), let sk2Product = try? await product.product() {
            let result = await Apphud.purchase(sk2Product)
            if Apphud.isSandbox(), result.transaction != nil {
                success = true
            } else if let subscription = result.subscription, subscription.isActive() {
                success = true
            } else if let purchase = result.nonRenewingPurchase, purchase.isActive() {
                success = true
            } else {
                success = false
            }
        } else {
            let result = await Apphud.purchase(product)
            if !result.success, Apphud.isSandbox(), result.transaction?.transactionState == .purchased {
                success = true
            } else if let subscription = result.subscription, subscription.isActive() {
                success = true
            } else if let purchase = result.nonRenewingPurchase, purchase.isActive() {
                success = true
            } else {
                success = false
            }
        }
        return success
    }
    
    @MainActor
    public static func fallbackRestore() async -> Bool {
        _ = await Apphud.restorePurchases()
        return Apphud.hasPremiumAccess()
    }
    
    public static func paywallShown(_ product: ApphudProduct) {
        if let paywall = allPaywalls.first(where: { $0.identifier == product.paywallIdentifier }) {
            assert(!openedPaywallIdentifiers.contains(paywall.identifier), "[ApphudBase] Paywall already shown: \(paywall.identifier)")
            openedPaywallIdentifiers.insert(paywall.identifier)
            Apphud.paywallShown(paywall)
        } else {
            assertionFailure("[ApphudBase] Failed to find paywall with following product: \(product.productId)")
        }
    }
    
    public static func paywallClosed(_ product: ApphudProduct) {
        if let paywall = allPaywalls.first(where: { $0.identifier == product.paywallIdentifier }) {
            assert(openedPaywallIdentifiers.remove(paywall.identifier) != nil, "[ApphudBase] Paywall not shown: \(paywall.identifier)")
            Apphud.paywallClosed(paywall)
        } else {
            assertionFailure("[ApphudBase] Failed to find paywall with following product: \(product.productId)")
        }
    }
}
