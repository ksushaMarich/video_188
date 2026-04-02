
import UIKit

import SwiftUI

enum SFProDisplay: String {
    case medium = "SF-Pro-Display-Medium"
    case regular = "SF-Pro-Display-Regular"
    case semibold = "SF-Pro-Display-Semibold"
    
    func of(size: CGFloat) -> Font {
        Font.custom(self.rawValue, size: size)
    }
}
