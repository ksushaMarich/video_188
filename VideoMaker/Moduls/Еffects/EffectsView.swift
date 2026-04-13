
import SwiftUI

struct EffectsView: View {
    @EnvironmentObject private var viewModel: VideoCreationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            libraryItemsList
        }
        .overlay(alignment: .top) {
            header
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(Color.mainBackground.ignoresSafeArea())
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text("Effects")
                .foregroundColor(.introSubtitle)
                .font(CabinetGroteskFont.medium.of(size: 17))

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(.backIcon)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }

                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 26)
        .padding(.top, 11)
        .padding(.bottom, 21)
        .background(
            BlurView(effect: .dark, intensity: 0.24)
                .ignoresSafeArea()
                .background(.mainBackground.opacity(0.8))
        )
    }

    // MARK: - Content

    private var libraryItemsList: some View {
        let items = EffectType.allCases
        
        return ScrollView {
            VStack(spacing: 16) {
                ForEach(Array(items.chunked(into: 2).enumerated()), id: \.offset) { _, pair in
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(pair) { item in
                            EffectsViewCard(
                                selectedEffect: $viewModel.selectedEffect,
                                effectType: item
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16 + 54)
        }
    }
}
