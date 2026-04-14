
import UIKit
import AVFoundation
import SwiftUI

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
        playerLayer.videoGravity = .resizeAspect

        // 👉 вот это важно
        Task {
            do {
                let tracks = try await item.asset.loadTracks(withMediaType: .video)

                if let track = tracks.first {
                    let size = track.naturalSize.applying(track.preferredTransform)
                    let fixedSize = CGSize(width: abs(size.width), height: abs(size.height))

                    await MainActor.run {
                        if fixedSize.width > 0, fixedSize.height > 0 {
                            self.onVideoSize?(fixedSize)
                        }
                    }
                }
            } catch {
                print("Failed to load tracks: \(error)")
            }
        }

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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        (layer as? AVPlayerLayer)?.frame = bounds
    }
}

struct InnerPlayer: UIViewRepresentable {
    let videoURL: URL
    var onVideoSize: (CGSize) -> Void
    var onProgress: (Double, Double) -> Void

    func makeUIView(context: Context) -> GenerationVideoPlayerUIView {
        let view = GenerationVideoPlayerUIView()
        view.onVideoSize = onVideoSize
        view.onProgress = onProgress
        view.configure(url: videoURL)
        return view
    }

    func updateUIView(_ uiView: GenerationVideoPlayerUIView, context: Context) {}
}
