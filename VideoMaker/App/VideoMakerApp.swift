
import SwiftUI

@main
struct VideoMakerApp: App {
    
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var isLoading = true

    var body: some Scene {
        WindowGroup {
            Group {
                if !isLoading  {
                    ContentView()
                        .environmentObject(purchaseManager)
                } else {
                    LaunchScreen()
                }
            }
            .task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}
