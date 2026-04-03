
import SwiftUI

@main
struct VideoMakerApp: App {
    
    @StateObject private var purchaseManager = PurchaseManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if purchaseManager.paywall != nil {
                    ContentView()
                        .environmentObject(purchaseManager)
                } else {
                    LaunchScreen()
                }
            }
        }
    }
}
