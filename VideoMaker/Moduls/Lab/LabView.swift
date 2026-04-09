internal import CoreData
import SwiftUI

struct LabView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject private var mainTabViewModel: MainTabViewModel
    @EnvironmentObject var mainViewModel: MainViewModel
    @StateObject private var viewModel = LabViewModel()
    @State private var selectedVideo: LibraryItem?
    @State private var headerHeight: CGFloat = 0

    var body: some View {
        ZStack {
            if mainViewModel.results.isEmpty {
                emptyView
            } else {
                content
            }
            VStack(spacing: 0) {
                Text("Your Creations")
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 11)
                    .padding(.bottom, 21)
                    .background(
                        BlurView(effect: .dark, intensity: 0.24)
                            .ignoresSafeArea()
                            .background(.mainBackground.opacity(0.8))
                    )
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    headerHeight = geo.size.height
                                }
                        }
                    )
                Spacer()
            }
        }
        .background(Color.mainBackground.ignoresSafeArea())
        .navigationDestination(item: $selectedVideo) { video in
            Group {
                if video.videoURL != nil {
                    GenerationView(libraryItem: video)
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        ScrollView(.vertical, showsIndicators: false) {
            libraryItemsList
        }
    }

    private var libraryItemsList: some View {
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]

        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(mainViewModel.results) { item in
                LabVideoCard(preset: item) {
                    selectedVideo = item
                }
            }
        }
        .padding(.top, headerHeight + 16)
        .padding(.horizontal, 16)
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
                mainTabViewModel.selectedTab = .main
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
                .contentShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, 24)
    }
}
