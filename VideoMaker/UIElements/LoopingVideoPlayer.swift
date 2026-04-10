import AVFoundation
import SwiftUI

struct LoopingVideoPlayer: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    @State private var playerObserver: NSObjectProtocol?

    var body: some View {
        Group {
            if let player = player {
                VideoPlayerRepresentable(player: .constant(player), videoGravity: .resizeAspectFill)
            } else {
                Rectangle()
                    .redacted(reason: .placeholder)
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            cleanup()
        }
        .allowsHitTesting(false)
    }

    private func setupPlayer() {
        cleanup()

        player = AVPlayer(url: videoURL)
        player?.isMuted = true
        player?.automaticallyWaitsToMinimizeStalling = false

        playerObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main)
        { _ in
            player?.seek(to: .zero)
            player?.play()
        }

        player?.play()
    }

    private func cleanup() {
        player?.pause()
        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        playerObserver = nil
        player = nil
    }
}

#Preview {
    if let url = Bundle.main.url(forResource: "mock_video", withExtension: "mp4") {
        LoopingVideoPlayer(videoURL: url)
            .frame(width: 200, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .background(Color.mainBackground)
    }
}
