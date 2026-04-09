import SwiftUI

struct LabVideoCard: View {
    let preset: LibraryItem
    var onTap: (() -> Void)?

    private let ratio: CGFloat = 164 / 200

    var body: some View {
        Button {
            onTap?()
        } label: {
            ZStack {
                if let videoURL = preset.videoURL {
                    LoopingVideoPlayer(videoURL: videoURL)
                        .allowsHitTesting(false)
                } else if let imageName = preset.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(ratio, contentMode: .fill)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .contentShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
