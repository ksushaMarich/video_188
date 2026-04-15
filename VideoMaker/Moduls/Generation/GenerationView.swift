
import SwiftUI

struct GenerationView: View  {
    
    @EnvironmentObject var viewModel: VideoCreationViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var generationState: GenerationState?
    
    var body: some View {
        VStack(spacing: 0) {
            if generationState == .fail {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(.backIcon)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(10)
                            .contentShape(Rectangle())
                        
                        
                    }
                    .padding(.leading, 16)
                    .padding(.bottom, 10)
                    Spacer()
                }
            }
            Spacer()
            if generationState != .fail,  generationState != nil {
                Image(.lightning)
                    .resizable()
                    .frame(width: 164, height: 164)
                    .padding(.bottom, 48)
            }
            Text(generationState?.title ?? "")
                .font(CabinetGroteskFont.extrabold.of(size: 40))
                .foregroundColor(.introSubtitle)
                .padding(.bottom, 8)
            Text(generationState?.subtitle ?? "")
                .font(CabinetGroteskFont.regular.of(size: 20))
                .foregroundColor(.introSubtitle)
            Spacer()
            if generationState == .fail {
                Button {
                    viewModel.generate()
                } label: {
                    HStack {
                        Text("Try Again")
                            .font(CabinetGroteskFont.bold.of(size: 16))
                            .foregroundColor(.textBlack)
                        Spacer()
                        Image(.replaceBlackIcon)
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, 12)
                    .padding(.vertical, 12)
                    .background(Color.introAccentSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .contentShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.mainBackground.ignoresSafeArea())
    }
}
