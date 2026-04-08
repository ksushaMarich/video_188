
import UIKit

final class ZeroInsetTextView: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
}
