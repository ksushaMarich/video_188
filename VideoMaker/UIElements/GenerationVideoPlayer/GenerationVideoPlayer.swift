
import SwiftUI
import AVFoundation

struct GenerationVideoPlayer: View {
    let videoURL: URL
    @State private var progress: Double = 0
    @State private var duration: Double = 1
    @State private var videoSize: CGSize?
    @State private var videoSizeHeight: CGFloat = 200
    
    struct VideoHeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 200
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            InnerPlayer(
                videoURL: videoURL,
                onVideoSize: { size in
                    videoSize = size
                },
                onProgress: {  current, total in
                    progress = current
                    duration = total
                }
            )
            .background(GeometryReader { geo in
                Color.clear
                    .preference(key: VideoHeightKey.self, value: geo.size.height)
            })
            VStack(spacing: 0) {
                Text("\(formatTime(progress)) / \(formatTime(duration))")
                    .font(CabinetGroteskFont.regular.of(size: 13))
                    .foregroundColor(.introSubtitle)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.introSubtitle.opacity(0.2))
                        .frame(height: 3)

                    GeometryReader { geo2 in
                        Capsule()
                            .fill(Color.introAccentSecondary)
                            .frame(width: geo2.size.width * (progress / duration), height: 3)
                    }
                }
                .frame(height: 3)
                .padding(.vertical, 15)
            }
            .padding(.horizontal, 16)
        }
        .frame(height: videoSizeHeight)
        .onPreferenceChange(VideoHeightKey.self) { newHeight in
            videoSizeHeight = newHeight
        }
    }
    
    private func formatTime(_ time: Double) -> String {
        guard !time.isNaN && !time.isInfinite else { return "0:00" }
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
