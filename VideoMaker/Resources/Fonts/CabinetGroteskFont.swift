
import UIKit

import SwiftUI

enum CabinetGroteskFont: String {
    
    case bold = "CabinetGrotesk-Bold"
    case medium = "CabinetGrotesk-Medium"
    case extrabold = "CabinetGrotesk-Extrabold"
    
    func of(size: CGFloat) -> Font {
        Font.custom(self.rawValue, size: size)
    }
}
