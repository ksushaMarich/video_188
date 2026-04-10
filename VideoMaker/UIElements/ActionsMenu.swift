import SwiftUI

struct ActionsMenu: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager

    var onGenerateAgain: (() -> Void)?
    var onUsePrompt: (() -> Void)?
    var onSaveToPhotos: (() -> Void)?
    var onShare: (() -> Void)?
    var onCancel: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 0) {
                menuButton(isPrem: !purchaseManager.isSubscribed, title: "Generate again", action: onGenerateAgain)
                Rectangle()
                    .fill(Color.red.opacity(0.1))
                    .frame(height: 1)
                menuButton(isPrem: false, title: "Use prompt", action: onUsePrompt)
                Rectangle()
                    .fill(Color.red.opacity(0.1))
                    .frame(height: 1)
                menuButton(isPrem: !purchaseManager.isSubscribed, title: "Save to Photos", action: onSaveToPhotos)
                Rectangle()
                    .fill(Color.red.opacity(0.1))
                    .frame(height: 1)
                menuButton(isPrem: !purchaseManager.isSubscribed, title: "Share", action: onShare)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.red))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Button {
                onCancel?()
            } label: {
                Text("Cancel")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.red))
                    .contentShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.horizontal, 24)
    }

    private func menuButton(isPrem: Bool, title: String, action: (() -> Void)?) -> some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 9) {

                Text(title)
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                BlurView(effect: .dark, intensity: 0.64))
            .contentShape(Rectangle())
        }
    }
}

#Preview("Actions Menu") {
    ZStack {
        Color.mainBackground
            .ignoresSafeArea()

        ActionsMenu(
            onGenerateAgain: { print("Generate again") },
            onUsePrompt: { print("Use prompt") },
            onSaveToPhotos: { print("Save to Photos") },
            onShare: { print("Share") },
            onCancel: { print("Cancel") })
    }
}
