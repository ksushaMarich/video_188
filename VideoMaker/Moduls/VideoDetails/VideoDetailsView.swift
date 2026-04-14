import Combine
import Photos
import SwiftUI
import UIKit
import Lottie

struct VideoDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var context
    @StateObject private var viewModel: VideoDetailsViewModel
    @State private var showActionsMenu = false
    @State private var shareItem: ShareItem?
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var mainTabViewModel: MainTabViewModel
    @EnvironmentObject private var generationLimitManager: GenerationLimitManager
    @EnvironmentObject var mainViewModel: MainViewModel
    @AppStorage("hasGeneratedAfterSubscription") private var hasGeneratedAfterSubscription: Bool = false

    @State private var showNotEnough = false
    @State private var showAllUsed = false
    @State private var showDeleteAlert = false
    @State private var showFeedbackAlert = false
    @State private var showGoToStoreAlert = false

    init(libraryItem: LibraryItem) {
        _viewModel = StateObject(wrappedValue: VideoDetailsViewModel(libraryItem: libraryItem))
    }

    var body: some View {
        ZStack {
            resultContent
            VStack {
                customToolBar
                Spacer()
            }
        }
        .onTapGesture {
            showActionsMenu = false
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(
            Color.mainBackground.ignoresSafeArea()
        )
        .sheet(item: $shareItem) { item in
            ActivitySheetView(url: item.url) {
                shareItem = nil
            }
            .presentationDetents([.medium, .large])
        }
        .alert("Do You Like The App?", isPresented: $showFeedbackAlert) {
            Button("No") {}
            Button("Yes") {
                showGoToStoreAlert = true
            }
        } message: {
            Text("We appreciate your feedback")
        }
        .alert("Please Leave a Review", isPresented: $showGoToStoreAlert) {
            Button("Go to the App Store", role: .cancel) {
                guard let url = URL(string: AppConfig.Links.review) else { return }
                UIApplication.shared.open(url)
            }
        } message: {
            Text("Positive reviews are a powerful motivation for us to excel")
        }
        .overlay(alignment: .top) {
            if showActionsMenu {
                actionsMenuOverlay()
                    .padding(.trailing, 68)
                    .padding(.leading, 126)
                    .padding(.top, 10)
            }
        }
        .overlay {
            if showDeleteAlert {
                ZStack {
                    BlurView(effect: .dark, intensity: 0.24)
                        .ignoresSafeArea()
                        .background(.mainBackground.opacity(0.8))
                    
                    deleteAlert
                }
            }
        }
        .overlay(alignment: .top) {
            if let isSuccessSeved = viewModel.isSuccessSeved {
                makeToastView(isSuccess: isSuccessSeved)
                    .padding(.top, 9)
            }
        }
        .onAppear {
            if purchaseManager.isSubscribed, !hasGeneratedAfterSubscription {
                showFeedbackAlert = true
                hasGeneratedAfterSubscription = true
            }
        }
    }
    
    private var deleteAlert: some View {
        VStack(spacing: 0) {
            VStack(spacing: 9){
                Text("Sure You Want\nTo Delete This Video?")
                    .font(CabinetGroteskFont.bold.of(size: 17))
                    .foregroundColor(.introSubtitle)
                    .multilineTextAlignment(.center)
                Text("This action cannot be undone")
                    .font(CabinetGroteskFont.regular.of(size: 13))
                    .foregroundColor(.introSubtitle)
            }
            .padding(.horizontal, 16)
            .padding(.top, 19)
            .padding(.bottom, 17)
            Divider()
            HStack(spacing: 1) {
                Button {
                    showDeleteAlert = false
                } label: {
                    Text("Cancel")
                        .font(CabinetGroteskFont.medium.of(size: 16))
                        .foregroundColor(.introSubtitle)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                }
                Divider()
                Button {
                    showDeleteAlert = false
                    mainViewModel.delete(context: context, item: viewModel.libraryItem)
                    dismiss()
                    print("action")
                } label: {
                    Text("Delete")
                        .font(CabinetGroteskFont.medium.of(size: 16))
                        .foregroundColor(.accentDestructive)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                }
            }
        }
        .background(Color.segmentedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 52.5)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func actionsMenuOverlay() -> some View {
        VStack(spacing: 0) {
            Button {
                showActionsMenu = false
                if purchaseManager.isSubscribed {
                    viewModel.saveVideoToPhotos()
                } else {
                    purchaseManager.isShowedPaywall = true
                }
            } label: {
                HStack {
                    Text("Save")
                        .font(CabinetGroteskFont.regular.of(size: 17))
                        .foregroundColor(.introSubtitle)
                    Spacer()
                    Image(.saveIcon)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(.leading, 16)
                .padding(.trailing, 10)
                .padding(.vertical, 10)
            }
            Divider()
            Button {
                showActionsMenu = false
                showDeleteAlert = true
            } label: {
                HStack {
                    Text("Delete")
                        .font(CabinetGroteskFont.regular.of(size: 17))
                        .foregroundColor(.accentDestructive)
                    Spacer()
                    Image(.redTrashIcon)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(.leading, 16)
                .padding(.trailing, 10)
                .padding(.vertical, 10)
            }
        }
        .background(.segmentedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var customToolBar: some View {
        Group {
            ZStack {
                HStack(spacing: 0) {
                    Button {
                        dismiss()
                    } label: {
                        Image(.backIcon)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(10)
                            .contentShape(Rectangle())
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showActionsMenu = true
                            }
                        } label: {
                            Image(.dots)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(10)
                                .contentShape(Rectangle())
                        }
                        Button {
                            showActionsMenu = false
                            if purchaseManager.isSubscribed {
                                if let url = viewModel.generatedVideoURL {
                                    shareItem = ShareItem(url: url)
                                }
                            } else {
                                purchaseManager.isShowedPaywall = true
                            }
                        } label: {
                            Image(.shareIcon)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(10)
                                .contentShape(Rectangle())
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .padding(.top, 8)
        .background(
            BlurView(effect: .dark, intensity: 0.24)
                .ignoresSafeArea()
                .background(.mainBackground.opacity(0.8))
            )
            
    }

    @ViewBuilder
    private func makeToastView(isSuccess: Bool) -> some View {
        Group {
            HStack(spacing: 8) {
                Image(isSuccess ? .checkmarkIcon : .crossIcon)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.vertical, 12)
                    .padding(.leading, 12)
                Text(isSuccess ? "Saved" : "Saving Failed")
                    .font(CabinetGroteskFont.medium.of(size: 15))
                    .foregroundColor( isSuccess ? .introSubtitle : .accentDestructive)
                    .padding(.trailing, 16)
            }
            .background(
                BlurView(effect: .dark, intensity: 0.4)
                    .background(isSuccess ? .introSubtitle.opacity(0.2) : .accentDestructive.opacity(0.2))
            )
            .clipShape(RoundedRectangle(cornerRadius: 100))
        }
    }

    @ViewBuilder
    private var resultContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 8) {
                if let url = viewModel.generatedVideoURL {
                    GenerationVideoPlayer (
                        videoURL: url, shouldAddWatermark: !purchaseManager.isSubscribed )
                        .frame(maxWidth: .infinity)
                }
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(viewModel.duration.rawValue)
                            .font(CabinetGroteskFont.medium.of(size: 17))
                            .foregroundColor(.introSubtitle)
                        Text("Duration")
                            .font(CabinetGroteskFont.medium.of(size: 15))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.leading, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.introSubtitle.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(viewModel.quality.rawValue)
                            .font(CabinetGroteskFont.medium.of(size: 17))
                            .foregroundColor(.introSubtitle)
                        Text("Resolution")
                            .font(CabinetGroteskFont.medium.of(size: 15))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.leading, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.introSubtitle.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                
                if let effect = viewModel.selectedTemplate {
                    HStack {
                        Text("Effect Title")
                            .font(CabinetGroteskFont.medium.of(size: 17))
                            .foregroundColor(.introSubtitle)
                            .padding(.vertical, 14)
                        Spacer()
                        Text(effect.rawValue.replacingOccurrences(of: "\n", with: " "))
                            .font(CabinetGroteskFont.regular.of(size: 17))
                            .foregroundColor(.introSubtitle.opacity(0.6))
                    }
                    .padding(.horizontal, 16)
                    .background(.introSubtitle.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 16)
                }
                
                Text(viewModel.prompt)
                    .font(CabinetGroteskFont.regular.of(size: 17))
                    .foregroundColor(.introSubtitle)
                    .padding(.leading, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.introSubtitle.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 16)
                
                Button {
                    mainViewModel.shouldUseSettingsFrom = viewModel.libraryItem
                    dismiss()
                    mainTabViewModel.selectedTab = .main
                } label: {
                    HStack(spacing: 0) {
                        Text("Use These Settings")
                            .font(CabinetGroteskFont.bold.of(size: 16))
                            .foregroundColor(.mainBackground)
                        Spacer()
                        Text((viewModel.duration == ._10 || viewModel.quality == ._1080) ? "3" : "1")
                            .foregroundColor( .textBlack)
                            .font(CabinetGroteskFont.bold.of(size: 16))
                        Image(.lightningIcon)
                            .resizable()
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
                .padding(.top, 16)
                .padding(.horizontal, 16)
            }
            .padding(.top, 72)
        }
    }
}

private struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

private struct ActivitySheetView: UIViewControllerRepresentable {
    let url: URL
    var onDismiss: (() -> Void)?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        vc.completionWithItemsHandler = { _, _, _, _ in
            onDismiss?()
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
