import AVFoundation
import SwiftUI

struct LoopingVideoPlayer: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    @State private var playerObserver: NSObjectProtocol?
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var restartTrigger = false

    var body: some View {
           Group {
               if let player = player {
                   VideoPlayerRepresentable(
                       player: .constant(player),
                       videoGravity: .resizeAspectFill
                   )
               } else {
                   Rectangle()
                       .redacted(reason: .placeholder)
               }
           }
           .onAppear {
               setupPlayer()
           }
           .onChange(of: scenePhase) {
               if scenePhase == .active {
                   restartTrigger.toggle()
                   resumePlayer()
               } else if scenePhase == .background {
                   pausePlayer()
               }
           }
           .onDisappear {
               cleanup()
           }
           .allowsHitTesting(false)
       }

    private func setupPlayer() {
        guard player == nil else { return }

        player = AVPlayer(url: videoURL)
        player?.isMuted = true
        player?.automaticallyWaitsToMinimizeStalling = false

        addLoopObserver()
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
    
    private func addLoopObserver() {
        playerObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
        }
    }
    
    private func pausePlayer() {
        player?.pause()
    }
    
    private func resumePlayer() {
        player?.play()
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
