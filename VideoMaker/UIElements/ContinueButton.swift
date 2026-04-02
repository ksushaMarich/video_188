
import SwiftUI

struct ContinueButton: View {
    let action: () -> Void
    var isDisabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text("Continue")
                .font(CabinetGroteskFont.bold.of(size: 16))
                .foregroundColor(.textBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.introAccentSecondary)
                )
                .contentShape(RoundedRectangle(cornerRadius: 8))
        }
//        .disabled(isDisabled)
    }
}
