
import UIKit

enum CabinetGroteskUIFont: String {
    case regular = "CabinetGrotesk-Regular"
    
    func of(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: self.rawValue, size: size) else {
            print("Font \(self.rawValue) not found. The system font was used.")
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
}
