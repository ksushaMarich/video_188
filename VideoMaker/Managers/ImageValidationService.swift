import UIKit
import UniformTypeIdentifiers

enum ImageValidationError: Equatable {
    case unsupportedFormat
    case tooLarge
    case resolutionTooSmall
    case invalidAspectRatio

    var title: String {
        switch self {
            case .unsupportedFormat: return "Unsupported Image Format"
            case .tooLarge: return "Image Is Too Large"
            case .resolutionTooSmall: return "Image Resolution Is Too Small"
            case .invalidAspectRatio: return "Invalid Aspect Ratio"
        }
    }

    var subtitle: String {
        switch self {
            case .unsupportedFormat: return "Please upload a JPG, PNG, or WebP image"
            case .tooLarge: return "Please upload an image smaller than 20 MB"
            case .resolutionTooSmall: return "The shortest side must be at least 300 px"
            case .invalidAspectRatio: return "The image ratio must be between 2:5 and 5:2"
        }
    }
}

enum ImageValidationResult {
    case valid
    case invalid(ImageValidationError)
}

final class ImageValidationService {
    static let shared = ImageValidationService()
    private let maxFileSizeBytes = 20 * 1024 * 1024
    private let minShortSidePixels: CGFloat = 300
    private let minAspectRatio = 2.0 / 5.0
    private let maxAspectRatio = 5.0 / 2.0

    private init() {}

    func validate(image: UIImage, data: Data?) -> ImageValidationResult {
        print("Starting image validation")
        if let error = validateFormat(data: data) {
            print("Format validation failed: \(error)")
            return .invalid(error)
        }
        if let error = validateSize(data: data, image: image) {
            print("Size validation failed: \(error)")
            return .invalid(error)
        }
        if let error = validateResolution(image: image) {
            print("Resolution validation failed: \(error)")
            return .invalid(error)
        }
        if let error = validateAspectRatio(image: image) {
            print("Aspect ratio validation failed: \(error)")
            return .invalid(error)
        }
        print("Image validation successful")
        return .valid
    }

    private func validateFormat(data: Data?) -> ImageValidationError? {
        guard let data = data, data.count >= 2 else { return nil }
        let bytes = [UInt8](data.prefix(12))
        if bytes[0] == 0xFF, bytes[1] == 0xD8 { return nil }
        if bytes[0] == 0x89, bytes[1] == 0x50, bytes[2] == 0x4E { return nil }
        if data.count >= 12, bytes[0] == 0x52, bytes[1] == 0x49, bytes[2] == 0x46, bytes[3] == 0x46 {
            if data.count >= 8 {
                let riff = String(bytes: [bytes[4], bytes[5], bytes[6], bytes[7]], encoding: .ascii)
                if riff == "WEBP" { return nil }
            }
        }
        return .unsupportedFormat
    }

    private func validateSize(data: Data?, image: UIImage) -> ImageValidationError? {
        if let data = data {
            if data.count > maxFileSizeBytes { return .tooLarge }
            return nil
        }
        if let jpeg = image.jpegData(compressionQuality: 1), jpeg.count > maxFileSizeBytes {
            return .tooLarge
        }
        return nil
    }

    private func validateResolution(image: UIImage) -> ImageValidationError? {
        let scale = image.scale
        let w = image.size.width * scale
        let h = image.size.height * scale
        let shortest = min(w, h)
        if shortest < minShortSidePixels { return .resolutionTooSmall }
        return nil
    }

    private func validateAspectRatio(image: UIImage) -> ImageValidationError? {
        let w = image.size.width
        let h = image.size.height
        guard h > 0 else { return .invalidAspectRatio }
        let ratio = w / h
        if ratio < minAspectRatio || ratio > maxAspectRatio { return .invalidAspectRatio }
        return nil
    }

    func validate(image: UIImage, itemProvider: NSItemProvider) async -> ImageValidationResult {
        var loadedData: Data?
        for typeId in [UTType.jpeg.identifier, UTType.png.identifier, "org.webmproject.webp"] {
            if itemProvider.hasItemConformingToTypeIdentifier(typeId) {
                loadedData = await withCheckedContinuation { cont in
                    itemProvider.loadDataRepresentation(forTypeIdentifier: typeId) { data, _ in
                        cont.resume(returning: data)
                    }
                }
                break
            }
        }
        if loadedData == nil, itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            loadedData = await withCheckedContinuation { cont in
                itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                    cont.resume(returning: data)
                }
            }
        }
        return validate(image: image, data: loadedData)
    }

    func validate(
        image: UIImage,
        itemProvider: NSItemProvider,
        completion: @escaping (ImageValidationResult) -> Void)
    {
        Task {
            let result = await validate(image: image, itemProvider: itemProvider)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
