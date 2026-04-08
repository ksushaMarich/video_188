import Combine
import AVFoundation
import Foundation
import UIKit

final class MainViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var isValidatingImage = false
    @Published var promt = ""
    @Published var generationMode: GenerationMode = .imageToVideo
    @Published var progressState: GenerationState? {
        didSet {
            if progressState != nil {
                isGeneration = true
            } else {
                isGeneration = false
            }
        }
    }
    @Published var generatedVideoURL: URL?
    @Published var generatedVideoData: Data?
    @Published var generatedVideo: LibraryItem? = nil
    @Published var isGeneration: Bool = false
    @Published var isImageToVideo: Bool = true {
        didSet {
            generationMode = isImageToVideo ? .imageToVideo : .textToVideo
        }
    }
    @Published var quality: Quality = ._768 {
        didSet {
            if quality == ._1080 && duration == ._10 {
                duration = ._6
            }
        }
    }
    @Published var duration: Duration = ._6 {
        didSet {
            if duration == ._10 && quality == ._1080 {
                quality = ._768
            }
        }
    }
    
    var price: Int {
        quality == ._1080 || duration == ._10 ? 3 : 1
    }

    func generate() {
        progressState = .preparing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard self?.progressState == .preparing else { return }
            self?.progressState = .inQueue
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard self?.progressState == .inQueue else { return }
            self?.progressState = .generation
        }
        switch generationMode {
        case .textToVideo:
            MiniMaxApiService.shared.generateVideoFromText(
                prompt: promt,
                quality: quality,
                duration: duration)
            { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleGenerationResult(result)
                }
            }
        case .imageToVideo:
            guard let image = selectedImage else { return }
            MiniMaxApiService.shared.generateVideoFromImage(
                image: image,
                prompt: promt,
                quality: quality,
                duration: duration)
            { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleGenerationResult(result)
                }
            }
        }
    }
    
    var canGenerate: Bool {
        let hasPrompt = !promt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let imageOk = generationMode == .textToVideo || selectedImage != nil
        return hasPrompt && imageOk && GenerationLimitManager.shared.canAfford(price: price)
    }
    
    @MainActor
    private func handleGenerationResult(_ result: Result<Data, Error>) {
        switch result {
            case let .success(data):
            finishWithVideoData(data)
            case .failure:
            progressState = .fail
        }
    }
    
    private func finishWithVideoData(_ data: Data) {
        generatedVideoData = data
        let fileName = "generated_\(UUID().uuidString).mp4"
        guard let permanentURL = getPermanentVideoURL(fileName: fileName) else {
            progressState = .fail
            return
        }
        do {
            try data.write(to: permanentURL)
            generatedVideoURL = permanentURL
//            resultPlayer = AVPlayer(url: permanentURL)
//            setupResultPlayerObserver()
        } catch {
            progressState = .fail
            return
        }
        moveToResult()
    }
    
    func moveToResult() {
        progressState = nil
        saveVideoToCoreData()
    }
    
    private func saveVideoToCoreData() {
        guard let videoURL = generatedVideoURL else { return }

        CoreDataManager.shared.generateThumbnail(from: videoURL) { [weak self] thumbnailImage in
            guard let self = self else { return }

            generatedVideo = CoreDataManager.shared.saveGeneratedVideo(
                videoURL: videoURL,
                prompt: self.promt,
                duration: self.duration.rawValue,
                quality: self.quality.rawValue,
                generationMode: self.generationMode.rawValue,
                selectedTemplateId: nil,
                thumbnailImage: thumbnailImage,
                sourceImage: self.generationMode == .imageToVideo ? self.selectedImage : nil)
        }
    }
    
    private func getPermanentVideoURL(fileName: String) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return nil
        }

        let videosDirectory = documentsDirectory.appendingPathComponent("GeneratedVideos")

        do {
            try FileManager.default.createDirectory(
                at: videosDirectory,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch {
            print("Error creating videos directory: \(error)")
            return nil
        }

        return videosDirectory.appendingPathComponent(fileName)
    }
}
