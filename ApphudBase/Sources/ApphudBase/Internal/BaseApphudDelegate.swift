import ApphudSDK

final class BaseApphudDelegate: ApphudDelegate {
	let onPaywallsDidFullyLoad: ([ApphudPaywall]) -> Void
	
	init(onPaywallsDidFullyLoad: @escaping ([ApphudPaywall]) -> Void) {
		self.onPaywallsDidFullyLoad = onPaywallsDidFullyLoad
	}
	
	func paywallsDidFullyLoad(paywalls: [ApphudPaywall]) {
		onPaywallsDidFullyLoad(paywalls)
	}
}
