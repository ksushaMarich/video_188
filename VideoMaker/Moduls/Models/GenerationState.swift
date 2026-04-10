import Foundation

enum GenerationState: CaseIterable {
    case preparing
    case inQueue
    case generation
    case fail

    var title: String {
        switch self {
            case .preparing:
                return "Generating Video"
            case .inQueue:
                return "Making Video"
            case .generation:
                return "Making Video"
            case .fail:
                return "Generation Error"
        }
    }

    var subtitle: String {
        switch self {
            case .preparing:
                return "Preparing..."
            case .inQueue:
                return "Queueing..."
            case .generation:
                return "Processing..."
            case .fail:
                return "Try again or quit"
        }
    }
}
