import SwiftUI
import UIKit

struct BlurView: UIViewRepresentable {
    let effect: UIBlurEffect.Style
    let intensity: CGFloat

    func makeUIView(context: Context) -> CustomIntensityVisualEffectView {
        let blurEffect = UIBlurEffect(style: effect)
        return CustomIntensityVisualEffectView(effect: blurEffect, intensity: intensity)
    }

    func updateUIView(_ uiView: CustomIntensityVisualEffectView, context: Context) {}
}
