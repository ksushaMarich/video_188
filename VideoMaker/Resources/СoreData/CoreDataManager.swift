internal import CoreData
import Foundation
import UIKit
import Combine

final class CoreDataManager: ObservableObject {
    let container: NSPersistentContainer
    @Published var isLoaded: Bool = false
    
    init() {
        container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            self.container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            
            DispatchQueue.main.async { [weak self] in
                self?.isLoaded = true
            }
        }
    }
}
