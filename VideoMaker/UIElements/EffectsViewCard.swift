
import SwiftUI

struct EffectsViewCard: View {
    
    @Binding var selectedEffect: EffectType? 
    let effectType: EffectType
    private var isSelected: Bool {
        selectedEffect == effectType
    }

    private let ratio: CGFloat = 164 / 200

    var body: some View {
        Button {
            if selectedEffect == effectType {
                selectedEffect = nil
            } else {
                selectedEffect = effectType
            }
        } label: {
            if let url = Bundle.main.url(forResource: effectType.fileName, withExtension: "mp4") {
                VStack(spacing: 0) {
                    LoopingVideoPlayer(videoURL: url)
                        .allowsHitTesting(false)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(ratio, contentMode: .fit) 
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.introAccentSecondary, lineWidth: 1)
                                .opacity(isSelected ? 1 : 0)
                        )
                    HStack {
                        Text(effectType.rawValue)
                            .font(CabinetGroteskFont.regular.of(size: 13))
                            .foregroundColor(.introSubtitle)
                            .multilineTextAlignment(.leading)
                            .padding(.vertical, 10)
                        Spacer()
                        Image(.circleCheckmarkIcon)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .opacity(isSelected ? 1 : 0)
                    }
                    .padding(.horizontal, 8)
                }
                .contentShape(Rectangle())
            }
        }
    }
}
