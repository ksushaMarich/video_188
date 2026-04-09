import AVFoundation
import AVKit
import SwiftUI

final class PlayerLayerView: UIView {
    var playerLayer: AVPlayerLayer? { layer as? AVPlayerLayer }

    override class var layerClass: AnyClass { AVPlayerLayer.self }

    override func layoutSubviews() {
        super.layoutSubviews()
        (layer as? AVPlayerLayer)?.frame = bounds
    }
}

struct VideoPlayerRepresentable: UIViewRepresentable {
    @Binding var player: AVPlayer
    var videoGravity: AVLayerVideoGravity = .resizeAspect

    func makeUIView(context: Context) -> PlayerLayerView {
        let view = PlayerLayerView()
        view.playerLayer?.player = player
        view.playerLayer?.videoGravity = videoGravity
        view.backgroundColor = .black
        return view
    }

    func updateUIView(_ uiView: PlayerLayerView, context: Context) {
        uiView.playerLayer?.player = player
        uiView.playerLayer?.videoGravity = videoGravity
        uiView.playerLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {}
}







