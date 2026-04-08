
import SwiftUI

@main
struct VideoMakerApp: App {
    
    @StateObject private var purchaseManager = PurchaseManager.shared
    @StateObject private var coreDataManager = CoreDataManager.shared
    @StateObject private var generationLimitManager = GenerationLimitManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if purchaseManager.paywall != nil && coreDataManager.isLoaded {
                    ContentView()
                        .environmentObject(purchaseManager)
                        .environmentObject(coreDataManager)
                        .environmentObject(generationLimitManager)
                } else {
                    LaunchScreen()
                }
            }
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
        }
    }
}
