
import SwiftUI
internal import CoreData

@main
struct VideoMakerApp: App {
    
    @StateObject private var purchaseManager = PurchaseManager.shared
    @StateObject private var coreDataManager = CoreDataManager()
    @StateObject var viewModel = MainViewModel()
    @StateObject private var generationLimitManager = GenerationLimitManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if purchaseManager.paywall != nil && coreDataManager.isLoaded && viewModel.isLoaded {
                    ContentView()
                        .environmentObject(purchaseManager)
                        .environmentObject(viewModel)
                        .environmentObject(generationLimitManager)
                        .environment(\.managedObjectContext, coreDataManager.container.viewContext)
                } else {
                    LaunchScreen()
                }
            }
            .onChange(of: coreDataManager.isLoaded) { _, newValue in
                if newValue {
                    viewModel.fetchCD(context: coreDataManager.container.viewContext)
                }
            }
        }
    }
}
