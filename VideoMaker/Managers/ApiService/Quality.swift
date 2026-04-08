import SwiftUI

enum Quality: String, Identifiable, CaseIterable {
    case _768 = "768P"
    case _1080 = "1080P"

    var id: String { rawValue }

    init(raw: String?) {
        if raw == "768P" {
            self = ._768
        } else {
            self = ._1080
        }
    }

    var resolution: String {
        switch self {
            case ._768:
                return "768P"
            case ._1080:
                return "1080P"
        }
    }
}
