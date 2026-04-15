
import SwiftUI

struct AllUsedView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("You’ve Reached\nYour Limit")
                .font(CabinetGroteskFont.extrabold.of(size: 48))
                .multilineTextAlignment(.center)
                .foregroundColor(.introSubtitle)
            Text("New generations will unlock soon")
                .font(CabinetGroteskFont.medium.of(size: 20))
                .foregroundColor(.introSubtitle)
            Button {
                dismiss()
            } label: {
                Image(.whiteCrossIcon)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .contentShape(Rectangle())
            }
            .padding(.top, 40)
        }
        .frame(maxWidth: .infinity)
        .background(
            BlurView(effect: .dark, intensity: 0.24)
                .ignoresSafeArea()
                .background(.mainBackground.opacity(0.8))
        )
    }
}
