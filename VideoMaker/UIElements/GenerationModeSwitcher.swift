
import SwiftUI

struct GenerationModeSwitcher1: View {
    @Binding var isImageToVideo: Bool

    var body: some View {
        HStack(spacing: 0) {
            button(
                title: "Image to Video",
                isSelected: isImageToVideo
            ) {
                isImageToVideo = true
            }

            button(
                title: "Text to Video",
                isSelected: !isImageToVideo
            ) {
                isImageToVideo = false
            }
        }
    }

    private func button(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 0) {

                Text(title)
                    .font(CabinetGroteskFont.medium.of(size: 15))
                    .foregroundColor(.introSubtitle)
                    .padding(.vertical, 12)

                Rectangle()
                    .fill(isSelected ? Color.introAccentSecondary : Color.clear)
                    .frame(height: 2)
                    .animation(.easeInOut(duration: 0.3), value: isSelected)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(.mainBackground)
    }
}
