import SwiftUI

enum AIPreset: String, CaseIterable, Identifiable {
    case aquraium
    case angelWings
    case flameOn
    case attackOfClones
    case turningMetal
    case dancing

    case muscleBurst
    case longHair

    case zoomIn
    case arcRight
    case rotation3D
    case zoomOut

    var id: String { rawValue }
}
