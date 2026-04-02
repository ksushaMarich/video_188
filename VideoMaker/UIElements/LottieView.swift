import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
    var filename: String
    var loopMode: LottieLoopMode = .loop
    var speed: CGFloat = 1.0

    func makeUIView(context: Context) -> some UIView {
        func build() -> UIView {
            let view = UIView(frame: .zero)
            let animationView = LottieAnimationView(name: filename)
            animationView.loopMode = loopMode
            animationView.animationSpeed = speed
            animationView.contentMode = .scaleAspectFit
            animationView.play()
            animationView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(animationView)
            NSLayoutConstraint.activate([
                animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
                animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
                animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
            return view
        }
        if Thread.isMainThread {
            return build()
        }
        return DispatchQueue.main.sync(execute: build)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
