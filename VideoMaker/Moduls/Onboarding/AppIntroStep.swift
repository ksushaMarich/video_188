enum AppIntroStep: Int, CaseIterable {
    case first
    case second
    case third
    case paywall

    var title: String {
        switch self {
            case .first:
                return "Creative AI Tool\nIn Your Hands"
            case .second:
                return "People Love\nThis App"
            case .third:
                return "Incredible Effects\nthat Wow!"
            case .paywall:
                return ""
        }
    }

    var subtitle: String {
        switch self {
            case .first:
                return "Unlock your creative potential\nwith the power of AI"
            case .second:
                return "Find out why our app receives such\nhigh praise from users"
            case .third:
                return "Explore tons of effects designed to\nperfectly match your vibe and style"
            case .paywall:
                return ""
        }
    }
}
