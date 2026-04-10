import AVFoundation
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
}
