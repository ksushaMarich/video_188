import Foundation
import UIKit

struct LibraryItem: Hashable, Identifiable {
    let id: String
    let text: String
    let imageName: String?
    let thumbnailImage: UIImage?
    let duration: String
    let resolution: String
    let videoURL: URL?
    let generationMode: String
    let selectedTemplate: AIPreset?
    let sourceImage: UIImage?
    let generatedVideo: GeneratedVideo?

    init(
        id: String,
        text: String,
        imageName: String? = nil,
        thumbnailImage: UIImage? = nil,
        duration: String,
        resolution: String,
        videoURL: URL? = nil,
        generationMode: String = GenerationMode.textToVideo.rawValue,
        selectedTemplate: AIPreset? = nil,
        sourceImage: UIImage? = nil,
        generatedVideo: GeneratedVideo? = nil)
    {
        self.id = id
        self.text = text
        self.imageName = imageName
        self.thumbnailImage = thumbnailImage
        self.duration = duration
        self.resolution = resolution
        self.videoURL = videoURL
        self.generationMode = generationMode
        self.selectedTemplate = selectedTemplate
        self.sourceImage = sourceImage
        self.generatedVideo = generatedVideo
    }

    init(from generatedVideo: GeneratedVideo) {
        id = generatedVideo.id?.uuidString ?? UUID().uuidString
        text = generatedVideo.prompt ?? ""
        imageName = nil
        thumbnailImage = generatedVideo.thumbnailData.flatMap { UIImage(data: $0) }
        duration = generatedVideo.duration ?? ""
        resolution = generatedVideo.quality ?? ""
        videoURL = generatedVideo.videoURL
        generationMode = generatedVideo.generationMode ?? GenerationMode.textToVideo.rawValue
        selectedTemplate = (generatedVideo.selectedTemplateId).flatMap { AIPreset(rawValue: $0) }
        sourceImage = generatedVideo.sourceImageData.flatMap { UIImage(data: $0) }
        self.generatedVideo = generatedVideo
    }

    init(from generatedVideo: GeneratedVideo, resolvedVideoURL: URL) {
        id = generatedVideo.id?.uuidString ?? UUID().uuidString
        text = generatedVideo.prompt ?? ""
        imageName = nil
        thumbnailImage = generatedVideo.thumbnailData.flatMap { UIImage(data: $0) }
        duration = generatedVideo.duration ?? ""
        resolution = generatedVideo.quality ?? ""
        videoURL = resolvedVideoURL
        generationMode = generatedVideo.generationMode ?? GenerationMode.textToVideo.rawValue
        selectedTemplate = (generatedVideo.selectedTemplateId).flatMap { AIPreset(rawValue: $0) }
        sourceImage = generatedVideo.sourceImageData.flatMap { UIImage(data: $0) }
        self.generatedVideo = generatedVideo
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: LibraryItem, rhs: LibraryItem) -> Bool {
        lhs.id == rhs.id
    }
}
