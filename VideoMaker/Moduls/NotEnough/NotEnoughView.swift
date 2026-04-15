
import SwiftUI

struct NotEnoughView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: VideoCreationViewModel
    @EnvironmentObject private var generationLimitManager: GenerationLimitManager
    
    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("Not Enough\nGenerations")
                .font(CabinetGroteskFont.extrabold.of(size: 48))
                .multilineTextAlignment(.center)
                .foregroundColor(.introSubtitle)
            Text("Сhange settings to reduce\nrequirements")
                .font(CabinetGroteskFont.medium.of(size: 20))
                .foregroundColor(.introSubtitle)
                .multilineTextAlignment(.center)
            HStack (spacing: 8){
                makeVidoSettingsItem(selectedItem: Duration._6, title: "Duration")
                makeVidoSettingsItem(selectedItem: Quality._768, title: "Resolution")
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            
            Button {
                viewModel.quality = ._768
                viewModel.duration = ._6
                generationLimitManager.consumeGenerations(
                    amount: 1,
                    isSubscribed: true)
                viewModel.generate()
                dismiss()
            } label: {
                HStack {
                    Text("Create Video")
                        .font(CabinetGroteskFont.bold.of(size: 16))
                        .foregroundColor(.textBlack)
                    Spacer()
                    HStack(spacing: 0) {
                        Text("1")
                            .font(CabinetGroteskFont.bold.of(size: 16))
                            .foregroundColor(.textBlack)
                        Image(.lightningIcon)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing, 12)
                .background(.introAccentSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .contentShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
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
    
    @ViewBuilder
    func makeVidoSettingsItem<T:CaseIterable & Identifiable & Hashable>(selectedItem: T, title: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                Text(title)
                    .font(CabinetGroteskFont.bold.of(size: 15))
                    .foregroundColor(.introSubtitle)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)
            HStack(spacing: 8) {
                ForEach(Array(T.allCases), id: \.id) { item in
                    segment(
                        title: getTitle(for: item),
                        selected: selectedItem == item
                    )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.segmentedBackground.opacity(0.8))
        )
    }
    
    private func segment(
        title: String,
        selected: Bool
    ) -> some View {
        Text(title)
            .font(CabinetGroteskFont.medium.of(size: 15))
            .foregroundColor(.introSubtitle)
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(
                Group {
                    if selected {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.introSubtitle.opacity(0.2))
                    }
                }
            )
            .contentShape(RoundedRectangle(cornerRadius: 8))
    }

    private func getTitle<T: CaseIterable & Identifiable & Hashable>(for item: T) -> String {
        if let item = item as? Quality {
            return item.resolution
        } else if let item = item as? Duration {
            return item.durationCard
        }
        return "\(item)"
    }
}

