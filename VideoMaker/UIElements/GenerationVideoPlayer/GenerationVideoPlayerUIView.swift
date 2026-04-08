
import UIKit
import AVFoundation

final class GenerationVideoPlayerUIView: UIView {
    private let player = AVQueuePlayer()
    private var playerLooper: AVPlayerLooper?
    var onProgress: ((Double, Double) -> Void)?
    private var timeObserver: Any?

    var onVideoSize: ((CGSize) -> Void)?

    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    func configure(url: URL) {
        let item = AVPlayerItem(url: url)
        playerLooper = AVPlayerLooper(player: player, templateItem: item)

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill

        addTimeObserver()

        player.play()
    }
    
    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.3, preferredTimescale: 600)

        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard
                let self,
                let duration = self.player.currentItem?.duration.seconds,
                duration > 0
            else { return }

            let current = time.seconds
            self.onProgress?(current, duration)
        }
    }
}
