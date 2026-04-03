import CoreData
import SwiftUI

struct LabView: View {
    @StateObject private var viewModel = LabViewModel()
    @EnvironmentObject private var mainViewModel: MainTabViewModel
    
    var body: some View {
        Color.mainBackground.ignoresSafeArea()
            .overlay {
                if viewModel.items.isEmpty {
                    emptyView
                }
            }
    }
    
    private var emptyView: some View {
        VStack(spacing: 48) {
            VStack(spacing: 8) {
                Text("Make a Video")
                    .font(CabinetGroteskFont.extrabold.of(size: 40))
                    .foregroundColor(.introSubtitle)
                
                Text("All your creations will\nbe gathered here")
                    .font(CabinetGroteskFont.regular.of(size: 20))
                    .foregroundColor(.introSubtitle)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                mainViewModel.selectedTab = .main
            } label: {
                HStack(spacing: 0) {
                    Text("Make a Video")
                        .font(CabinetGroteskFont.bold.of(size: 16))
                        .foregroundColor(.mainBackground)
                    Spacer()
                    Image(.lightningIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.introAccentSecondary))
            }
        }
        .padding(.horizontal, 24)
    }
}
