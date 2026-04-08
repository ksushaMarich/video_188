import SwiftUI
import UIKit

final class CustomIntensityVisualEffectView: UIVisualEffectView {
    init(effect: UIVisualEffect, intensity: CGFloat) {
        theEffect = effect
        customIntensity = intensity
        super.init(effect: nil)
        setupView()
    }

    required init?(coder: NSCoder) {
        nil
    }

    deinit {
        animator?.stopAnimation(true)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        effect = nil
        animator?.stopAnimation(true)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in
            self.effect = theEffect
        }
        animator?.fractionComplete = customIntensity
    }

    private func setupView() {
        backgroundColor = .clear
    }

    private let theEffect: UIVisualEffect
    private let customIntensity: CGFloat
    private var animator: UIViewPropertyAnimator?
}
