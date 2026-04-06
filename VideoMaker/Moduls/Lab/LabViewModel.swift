import Combine
import CoreData
import Foundation

final class LabViewModel: ObservableObject {
    @Published var items: [Int] = []
}
