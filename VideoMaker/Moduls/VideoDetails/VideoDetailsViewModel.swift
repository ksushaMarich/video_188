import AVFoundation
import Photos
public import CoreData
import Foundation
import UIKit
import Combine

private let maxPromptLength = 2000

@MainActor
final class VideoDetailsViewModel: ObservableObject {
    @Published var prompt = ""
    @Published var generationMode: GenerationMode = .textToVideo
    @Published var selectedTemplate: AIPreset?
    @Published var selectedImage: UIImage?
    @Published var quality: Quality = ._768
    @Published var duration: Duration = ._6
    @Published var generatedVideoURL: URL?
    @Published var toast: GenerationToastKind?
    @Published var toastDismissTask: Task<Void, Never>?

    private let connectorLength = 3


    init(libraryItem: LibraryItem) {
        generatedVideoURL = libraryItem.videoURL
        selectedTemplate = libraryItem.selectedTemplate
        let limit = libraryItem.selectedTemplate
            .map { _ in max(0, maxPromptLength /*- $0.presetPrompt.count*/ - connectorLength) } ?? maxPromptLength
        prompt = String(libraryItem.text.prefix(limit))
        selectedImage = libraryItem.sourceImage
        duration = Duration(raw: libraryItem.duration)
        quality = Quality(raw: libraryItem.resolution)
        generationMode = GenerationMode(rawValue: libraryItem.generationMode) ?? .textToVideo
    }
    
    func saveVideoToPhotos() {
        Task { @MainActor in
            toastDismissTask?.cancel()
            await saveVideoToPhotosIfGranted()
        }
    }

    private func saveVideoToPhotosIfGranted() async {
        guard let url = generatedVideoURL else { return }
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
                        self.toast = .downloaded
                        self.scheduleToastDismiss()
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
                toast = nil
            }
        }
    }
}
