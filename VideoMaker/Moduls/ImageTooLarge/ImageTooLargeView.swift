
import SwiftUI

struct ImageTooLargeView: View {
    
    var fromPhotos: () -> Void
    var newImage: () -> Void
    var cancel: () -> Void
    
    var body: some View {
        Group {
            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("Image Is Too Large")
                        .font(CabinetGroteskFont.bold.of(size: 17))
                        .foregroundStyle(.introSubtitle)
                    Text("Pick an image smaller than 20 MB")
                        .font(CabinetGroteskFont.regular.of(size: 13))
                        .foregroundStyle(.introSubtitle)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 17)
                .padding(.top, 19)
                Divider()
                Button {
                    fromPhotos()
                } label: {
                    Text("Upload From Photos")
                        .font(CabinetGroteskFont.bold.of(size: 17))
                        .foregroundStyle(.introSubtitle)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                }
                Divider()
                Button {
                    newImage()
                } label: {
                    Text("Make a New Image")
                        .font(CabinetGroteskFont.bold.of(size: 17))
                        .foregroundStyle(.introSubtitle)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                }
                Divider()
                Button {
                    cancel()
                } label: {
                    Text("Cancel")
                        .font(CabinetGroteskFont.bold.of(size: 17))
                        .foregroundStyle(.introSubtitle)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                }
            }
            .background(Color.segmentedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(52.5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            BlurView(effect: .dark, intensity: 0.24)
                .ignoresSafeArea()
                .background(.mainBackground.opacity(0.8))
        )
    }
}
