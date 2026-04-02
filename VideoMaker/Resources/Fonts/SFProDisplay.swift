
import UIKit

import SwiftUI

enum SFProDisplay: String {
    case regular = "SF-Pro-Display-Regular"
    
    func of(size: CGFloat) -> Font {
        Font.custom(self.rawValue, size: size)
    }
}
