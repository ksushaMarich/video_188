import SwiftUI

enum Duration: String, Identifiable, CaseIterable {
    case _6 = "6 seconds"
    case _10 = "10 seconds"

    var id: String { rawValue }

    init(raw: String?) {
        if raw == "6 seconds" {
            self = ._6
        } else {
            self = ._10
        }
    }

    var duration: String {
        switch self {
            case ._6:
                return "6"
            case ._10:
                return "10"
        }
    }

    var durationCard: String {
        switch self {
            case ._6:
                return "6 Sec"
            case ._10:
                return "10 Sec"
        }
    }
}
