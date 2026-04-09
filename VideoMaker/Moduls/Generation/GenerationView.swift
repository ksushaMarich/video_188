import Combine
import Photos
import SwiftUI
import UIKit
import Lottie

struct GenerationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: GenerationViewModel
    @State private var showActionsMenu = false
    @State private var shareItem: ShareItem?
    @State private var toast: GenerationToastKind?
    @State private var toastDismissTask: Task<Void, Never>?
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var generationLimitManager: GenerationLimitManager

    @State private var showNotEnough = false
    @State private var showAllUsed = false

    init(libraryItem: LibraryItem) {
        _viewModel = StateObject(wrappedValue: GenerationViewModel(libraryItem: libraryItem))
    }

    var body: some View {
        ZStack {
            resultContent
            VStack {
                customToolBar
                Spacer()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(
            Color.mainBackground.ignoresSafeArea()
        )
        .apply(actionsMenuOverlay)
    }

    private func actionsMenuOverlay(_ base: some View) -> some View {
        base.overlay {
            ZStack(alignment: .bottom) {
                if showActionsMenu {
                    Color.fillTertiary
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showActionsMenu = false
                            }
                        }
                        .transition(.opacity)
                }
                if showActionsMenu {
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        ActionsMenu(
                            onGenerateAgain: {
                                print("generate")
                            },
                            onUsePrompt: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showActionsMenu = false
                                }
                                print("onUsePrompt")
                            },
                            onSaveToPhotos: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showActionsMenu = false
                                }
                                if purchaseManager.isSubscribed {
                                    saveVideoToPhotos()
                                } else {
                                    purchaseManager.isShowedPaywall = true
                                }
                            },
                            onShare: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showActionsMenu = false
                                }
                                if purchaseManager.isSubscribed {
                                    if let url = viewModel.generatedVideoURL {
                                        shareItem = ShareItem(url: url)
                                    }
                                } else {
                                    purchaseManager.isShowedPaywall = true
                                }
                            },
                            onCancel: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showActionsMenu = false
                                }
                            })
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: showActionsMenu)
        }
    }

    private func saveVideoToPhotos() {
        Task { @MainActor in
            toastDismissTask?.cancel()
            await saveVideoToPhotosIfGranted()
        }
    }

    private func saveVideoToPhotosIfGranted() async {
        guard let url = viewModel.generatedVideoURL else { return }
        let granted = await PermissionService.shared.requestPhotoLibraryPermission()
        guard granted else {
            await MainActor.run { toast = nil }
            return
        }
        let startTime = Date()
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        } completionHandler: { success, error in
            Task { @MainActor in
                if success {
                    let elapsed = Date().timeIntervalSince(startTime)
                    let remaining = max(0, 2.0 - elapsed)
                    if remaining > 0 {
                        try? await Task.sleep(for: .seconds(remaining))
                    }
                    if !Task.isCancelled {
                        toast = .downloaded
                        scheduleToastDismiss()
                    }
                }
            }
        }
    }

    private func scheduleToastDismiss() {
        toastDismissTask?.cancel()
        toastDismissTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            if !Task.isCancelled {
                withAnimation(.easeInOut(duration: 0.25)) {
                    toast = nil
                }
            }
        }
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
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showActionsMenu = true
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
                if toast != nil {
                    toastView
                        .transition(.opacity)
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

    private var toastView: some View {
        Group {
            if let kind = toast {
                HStack(spacing: 8) {
                    switch kind {
                    case .downloaded, .deleted:
                        HStack(spacing: 0) {
                            Image(kind == .deleted ? .trashIcon : .checkmarkIcon)
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text(kind == .deleted ? "Video Deleted" : "Saved")
                                .font(CabinetGroteskFont.medium.of(size: 15))
                                .foregroundColor(.introSubtitle)
                        }
                        .background {
                            BlurView(effect: .dark, intensity: 0.16)
                                .ignoresSafeArea()
                                .background(Color.introSubtitle.opacity(0.2))
                        }
                    case .failed:
                        HStack(spacing: 0) {
                            Image(.crossIcon)
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Saving Failed")
                                .font(CabinetGroteskFont.medium.of(size: 15))
                                .foregroundColor(.red)
                        }
                    }
                }
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
            }
        }
        .opacity(toast != nil ? 1 : 0)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var resultContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 8) {
                if let url = viewModel.generatedVideoURL {
                    GenerationVideoPlayer (
                        videoURL: url )
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

//                if let preset = viewModel.selectedTemplate {
//                    templateCard(preset)
//                }
                Text(viewModel.prompt)
                    .font(CabinetGroteskFont.regular.of(size: 17))
                    .foregroundColor(.introSubtitle)
                    .padding(.leading, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.introSubtitle.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 16)
            }
            .padding(.top, 72)
        }
    }
}

private enum GenerationToastKind {
    case failed
    case downloaded
    case deleted
}

private struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}
