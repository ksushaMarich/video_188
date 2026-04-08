import Foundation

enum GenerationState: CaseIterable {
    case preparing
    case inQueue
    case generation
    case fail

    var title: String {
        switch self {
            case .preparing:
                return "Preparing your scene…"
            case .inQueue:
                return "In queue…"
            case .generation:
                return "Generating your video…"
            case .fail:
                return "Generating your video…"
        }
    }

    var subtitle: String {
        switch self {
            case .preparing:
                return "Setting up your assets and optimizing\ngeneration settings"
            case .inQueue:
                return "Your request is waiting for available\nprocessing power"
            case .generation:
                return "Rendering frames, applying motion, and\nbuilding your scene in real time"
            case .fail:
                return "Rendering frames, applying motion, and\nbuilding your scene in real time"
        }
    }
}
