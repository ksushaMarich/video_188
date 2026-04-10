import Lottie
import SwiftUI

struct VideoCreationView: View {
    @StateObject private var viewModel = VideoCreationViewModel()
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var mainViewModel: MainViewModel
    @EnvironmentObject private var generationLimitManager: GenerationLimitManager
    
    
    @FocusState private var isPromptFocused: Bool
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showEffectView = false
    @State private var showGalleryOrCamera = false
    @State private var showImageSelectionOverlay = false
    @State private var hasShownInitialImageOverlay = false
    @State private var isImageInvalid = false
    
    @State private var showNotEnough = false
    @State private var showAllUsed = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                customToolBar
                    .background(Color.mainBackground.ignoresSafeArea())
                content
            }
        }
        .navigationDestination(isPresented: $showEffectView, destination: {
            Text("Effects")
        })
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $viewModel.selectedImage) { image, provider in
                viewModel.isValidatingImage = true
                if viewModel.isValidSize(data: nil, image: image) {
                    viewModel.selectedImage = image
                    hasShownInitialImageOverlay = true
                    showImageSelectionOverlay = true
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(2))
                        showImageSelectionOverlay = false
                    }
                } else {
                    isImageInvalid = true
                }
            }
        }
        
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { image in
                if viewModel.isValidSize(data: nil, image: image) {
                    viewModel.selectedImage = image
                    hasShownInitialImageOverlay = true
                    showImageSelectionOverlay = true
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(2))
                        showImageSelectionOverlay = false
                    }
                } else {
                    isImageInvalid = true
                }
            }
            .background(.black)
        }
        .fullScreenCover(isPresented: $showGalleryOrCamera) {
            galleryOrCameraView
                .background(TransparentBackground())
        }
        .fullScreenCover(isPresented: $viewModel.isGeneration) {
            if let generatedVideo = viewModel.generatedVideo {
                VideoDetailsView(libraryItem: generatedVideo)
                    .onAppear {
                        viewModel.promt = ""
                        viewModel.duration = ._6
                        viewModel.quality = ._768
                        viewModel.selectedImage = nil
                    }
            } else {
                GenerationView(generationState: $viewModel.progressState)
                    .environmentObject(viewModel)
            }
        }
//        .fullScreenCover(isPresented: $showGalleryOrCamera) {
//            galleryOrCameraView
//                .background(.clear)
//        }
        .onTapGesture {
            hideKeyboard()
        }
        .onChange(of: viewModel.generatedVideoURL) { _, newValue in
            guard let url = newValue else { return }
            
            viewModel.generateThumbnail(from: url) { thumbnailImage in
                viewModel.generatedVideo = mainViewModel.create(context: context, videoURL: url, prompt: viewModel.promt, duration: viewModel.duration.rawValue, quality: viewModel.duration.rawValue, generationMode: viewModel.generationMode.rawValue, thumbnailImage: thumbnailImage)
            }
        }
    }
    
    private var customToolBar: some View {
        VStack {
            HStack(spacing: 0) {
                Text("Create a Video")
                    .font(CabinetGroteskFont.medium.of(size: 17))
                    .foregroundColor(.introSubtitle)
                    .padding(.vertical, 11)
                Spacer()
                HStack(spacing: 0) {
                    Text("\(generationLimitManager.generationsRemaining)")
                        .font(CabinetGroteskFont.medium.of(size: 14))
                        .foregroundColor(.introSubtitle)
                        .padding(.trailing, 4)
                    
                    Image(.lightningLightIcon)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(.trailing, 10)
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 16)
            GenerationModeSwitcher1(isImageToVideo: $viewModel.isImageToVideo)
                .padding(.horizontal, 16)
        }
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isImageToVideo {
                    imagePicker
                }
                effectsButton
                promtInput
                videoSettings
                generateButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .padding(.bottom, 48)
        }
        .scrollIndicators(.hidden)
    }
    
    private var imagePicker: some View {
        Group {
            if let image = viewModel.selectedImage {
                VStack(spacing: 0) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Button {
                        showGalleryOrCamera = true
                    } label: {
                        HStack(spacing: 8) {
                            Text("Replace image")
                                .foregroundColor(.introSubtitle)
                                .font(CabinetGroteskFont.medium.of(size: 14))
                            Image(.replaceIcon)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(.vertical, 12)
                        }
                        .padding(.horizontal, 16)
                        .contentShape(Rectangle())
                    }
                }
            } else {
                VStack(spacing: 0) {
                    Button {
                        showGalleryOrCamera = true
                    } label: {
                        VStack(spacing: 0) {
                            HStack(spacing: 8) {
                                Text("Upload Your Image")
                                    .font(CabinetGroteskFont.bold.of(size: 16))
                                    .foregroundColor(.introSubtitle)
                                Spacer()
                                Image(.plusIcon)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .padding(.vertical, 12)
                            }
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.introSubtitle.opacity(0.2)))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .contentShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    HStack {
                        Text("20 MB Max")
                            .font(CabinetGroteskFont.medium.of(size: 15))
                            .foregroundColor(.introSubtitle.opacity(0.3))
                        Spacer()
                        Text("JPG, PNG, WebP")
                            .font(CabinetGroteskFont.medium.of(size: 15))
                            .foregroundColor(.introSubtitle.opacity(0.3))
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 6)
                }
            }
        }
    }
    
    private var effectsButton: some View {
        Button {
            showEffectView = true
        } label: {
            HStack(spacing: 0) {
                Text("Effects")
                    .font(CabinetGroteskFont.medium.of(size: 17))
                    .foregroundStyle(.introSubtitle)
                Spacer()
                HStack(spacing: 12)  {
                    Text("None")
                        .font(CabinetGroteskFont.regular.of(size: 17))
                        .foregroundStyle(.introSubtitle.opacity(0.6))
                    Image(.forwardIcon)
                        .resizable()
                        .frame(width: 8, height: 24)
                        .padding(.vertical, 4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .padding(.horizontal, 16)
            .background(Color.introSubtitle.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .contentShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private var promtInput: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topLeading) {
                TextField("", text: promtBinding, axis: .vertical)
                    .foregroundColor(.introSubtitle)
                    .font(CabinetGroteskFont.regular.of(size: 17))
                    .focused($isPromptFocused)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .scrollIndicators(.hidden)

                if viewModel.promt.isEmpty {
                    Text("Describe your vision")
                        .foregroundColor(.introSubtitle.opacity(0.6))
                        .font(CabinetGroteskFont.regular.of(size: 17))
                        .multilineTextAlignment(.leading)
                        .allowsHitTesting(false)
                }
            }
            
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(minHeight: 124, maxHeight: 226, alignment: .top)
            .background(.introSubtitle.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            HStack(alignment: .bottom, spacing: 0) {
                let isTooLong = viewModel.promt.count >= 2000
                Text(verbatim: "\(viewModel.promt.count) • 2000 Symbols")
                    .foregroundColor(isTooLong ? .accentDestructive : .introSubtitle.opacity(0.3))
                    .font(CabinetGroteskFont.medium.of(size: 15))
                Spacer()
                if isTooLong {
                    Text("Prompt is too long!")
                        .foregroundColor(.accentDestructive)
                        .font(CabinetGroteskFont.medium.of(size: 15))
                }
            }
            .padding(.bottom, 6)
        }
        .onTapGesture {
            isPromptFocused = true
        }
    }
    
    private var promtBinding: Binding<String> {
        Binding(
            get: { viewModel.promt },
            set: { newValue in
                viewModel.promt = newValue
            }
        )
    }
    
    private var videoSettings: some View {
        VStack(spacing: 8) {
            HStack(spacing: 0) {
                Text("Video Settings")
                    .font(CabinetGroteskFont.regular.of(size: 20))
                    .foregroundStyle(.introSubtitle.opacity(0.6))
                Spacer()
            }
            .padding(.vertical, 10)
            HStack(spacing: 8) {
                VideoSettingsSegmentedControl(selection: $viewModel.duration, title: "Duration")
                VideoSettingsSegmentedControl(selection: $viewModel.quality, title: "Resolution")
            }
        }
    }
    
    private var generateButton: some View {
        Button {
            if generationLimitManager.canAfford(price: viewModel.price) {
                generationLimitManager.consumeGenerations(
                    amount: viewModel.price,
                    isSubscribed: purchaseManager.isSubscribed)
                viewModel.generate()
            } else if !generationLimitManager.canAfford(price: viewModel.price) && purchaseManager
                .isSubscribed
            {
                if generationLimitManager.generationsRemaining != 0 {
                    showNotEnough = true
                } else {
                    showAllUsed = true
                }
            } else {
                purchaseManager.isShowedPaywall = true
            }
        } label: {
            let canGenerate = viewModel.canGenerate
            Group {
                HStack(spacing: 8) {
                    Text("Create Video")
                        .foregroundColor(canGenerate ? .textBlack : .introSubtitle)
                        .font(CabinetGroteskFont.bold.of(size: 16))
                    Spacer()
                    Text("\(viewModel.price)")
                        .foregroundColor(canGenerate ? .textBlack : .introSubtitle)
                        .font(CabinetGroteskFont.bold.of(size: 16))
                    Image(canGenerate ? .lightningIcon : .lightningLightIcon)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .opacity(canGenerate ? 1 : 0.15)
                .padding(.leading, 16)
                .padding(.trailing, 12)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(canGenerate ? .introAccentSecondary : .introSubtitle.opacity(0.05))
                    .shadow(
                        color: .black.opacity(0.25),
                        radius: 0,
                        x: 0,
                        y: 4))
            .contentShape(RoundedRectangle(cornerRadius: 8))
            .padding(.top, 16)
        }
        .disabled(!viewModel.canGenerate)
    }
    
    @ViewBuilder
    private var galleryOrCameraView: some View {
        VStack(spacing: 16) {
            Spacer()
            Button {
                showGalleryOrCamera = false
                Task {
                    if await PermissionService.shared.requestPhotoLibraryPermission() {
                        showImagePicker = true
                    }
                }
            } label: {
                HStack{
                    Text("Upload From Photos")
                        .foregroundColor(.textBlack)
                        .font(CabinetGroteskFont.bold.of(size: 16))
                    Spacer()
                    Image(.galleryIcon)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(.leading, 16)
                .padding(.trailing, 12)
                .padding(.vertical, 12)
                .background(.introAccentSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .contentShape(RoundedRectangle(cornerRadius: 8))
            }
            Button {
                showGalleryOrCamera = false
                Task {
                    if await PermissionService.shared.requestCameraUsageAccess() {
                        showCamera = true
                    }
                }
            } label: {
                HStack{
                    Text("Take a New Photo")
                        .foregroundColor(.introSubtitle)
                        .font(CabinetGroteskFont.bold.of(size: 16))
                    Spacer()
                    Image(.cameraIcon)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .padding(.leading, 16)
                .padding(.trailing, 12)
                .padding(.vertical, 12)
                .background(.introSubtitle.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .contentShape(RoundedRectangle(cornerRadius: 8))
            }
            Button {
                showGalleryOrCamera = false
            } label: {
                Image(.whiteCrossIcon)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .contentShape(Rectangle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .background(
            BlurView(effect: .dark, intensity: 0.24)
                .ignoresSafeArea()
                .background(.textBlack.opacity(0.8))
        )
    }
}
