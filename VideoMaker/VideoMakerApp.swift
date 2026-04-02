//
//  VideoMakerApp.swift
//  VideoMaker
//
//  Created by Ксения Маричева on 01.04.2026.
//

import SwiftUI

@main
struct VideoMakerApp: App {
    
    @StateObject private var purchaseManager = PurchaseManager.shared
    
//    @StateObject private var coreDataManager = CoreDataManager.shared
//    @StateObject private var generationLimitManager = GenerationLimitManager.shared
    @State private var isLoading = true

    var body: some Scene {
        WindowGroup {
            Group {
                if !isLoading  {
                    ContentView()
                        .environmentObject(purchaseManager)
//                        .environmentObject(coreDataManager)
//                        .environmentObject(generationLimitManager)
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
            .onAppear {
                for family in UIFont.familyNames {
                    print(family)
                    for name in UIFont.fontNames(forFamilyName: family) {
                        print("  \(name)")
                    }
                }
            }
//            .environment(\.managedObjectContext, CoreDataManager.shared.context)
        }
    }
}
