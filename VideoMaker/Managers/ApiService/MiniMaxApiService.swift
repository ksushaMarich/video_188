import AVFoundation
import Foundation
import ObfuscateMacro
import SwiftUI
import UIKit
import ApphudSDK

private enum MockVideoSource: String {
    case text
    case image
    var fileName: String { "mock_video_\(rawValue).data" }
}

@MainActor
final class MiniMaxApiService {
    static var shared = MiniMaxApiService()

    private let useMocks: Bool
    private let shouldFail: Bool
    private var apiKey =
        #ObfuscatedString("d92ffca624a2d73bb26c7f509314d1d3")
    private var baseURL = #ObfuscatedString("http://187.77.223.2:8000/minimax/")
        #ObfuscatedString("d92ffca624a2d73bb26c7f509314d1d3")
    private var ks = #ObfuscatedString(
"""
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAk02/m02R2cNCnl9BDP/x
XoXjJiSNwfcQUsyrOYUjauf56SlUrfA2BCI1LHX/i/EnK+pJuY7WbajTYcEOtCUM
hhcAHjcvgerk4PgaCueCS3QMskjOsSh6JmmO69MQHHL2BAUNmfVhfTnyU+hDiT3q
8dJtJSoNCb/kGnSskmfujtplKnlcCZ++2gawGOh+ghhXzfGEK9h7c7RRktzgUlVQ
8smTl+Nlccb2sANnndeIODD4dTskbuPA3Pxa0l+fGRsVJYICH3BXtf2a+J/C6zSO
UmcLypk8yC981U2nfvMy+89JKo5ITY1Qwq1qMMUsdFd1JExRlSUscp+LQ1IoUw6X
wwIDAQAB
-----END PUBLIC KEY-----
""")

    private var mockVideosDirectory: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("MockVideos")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    #if DEBUG
        private var mockVideosDocumentsDirectory: URL {
            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                .appendingPathComponent("MockVideos")
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            return dir
        }
    #endif

    #if DEBUG
        init() {
            shouldFail = false
//            useMocks = false
            useMocks = true
        }
    #else
        init() {
            shouldFail = false
            useMocks = false
        }
    #endif

    func generateVideoFromText(
        prompt: String,
        quality: Quality = ._768,
        duration: Duration = ._6,
        completion: @escaping (Result<Data, Error>) -> Void)
    {
        #if DEBUG
            if useMocks { return mock_generateVideoFromText(
                prompt: prompt,
                quality: quality,
                duration: duration,
                completion: completion) }
        #endif
        return real_generateVideoFromText(prompt: prompt, quality: quality, duration: duration, completion: completion)
    }

    func generateVideoFromImage(
        image: UIImage,
        prompt: String,
        quality: Quality = ._768,
        duration: Duration = ._6,
        completion: @escaping (Result<Data, Error>) -> Void)
    {
        #if DEBUG
            if useMocks { return mock_generateVideoFromImage(
                image: image,
                prompt: prompt,
                quality: quality,
                duration: duration,
                completion: completion) }
        #endif
        return real_generateVideoFromImage(
            image: image,
            prompt: prompt,
            quality: quality,
            duration: duration,
            completion: completion)
    }

    private let watermarkHorizontalInset: CGFloat = 26
    private let watermarkVerticalInset: CGFloat = 100

    func applyWatermark(to videoData: Data, completion: @escaping (Result<Data, Error>) -> Void) {
        let tempDir = FileManager.default.temporaryDirectory
        let inputURL = tempDir.appendingPathComponent("input_\(UUID().uuidString).mp4")
        let outputURL = tempDir.appendingPathComponent("output_\(UUID().uuidString).mp4")

        do {
            try videoData.write(to: inputURL)
        } catch {
            DispatchQueue.main.async { completion(.failure(error)) }
            return
        }

        let asset = AVURLAsset(url: inputURL)
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            DispatchQueue.main.async {
                completion(.failure(NSError(
                    domain: "MiniMaxApiService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No video track"])))
            }
            return
        }

        let videoSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
        let size = CGSize(width: abs(videoSize.width), height: abs(videoSize.height))

        let composition = AVMutableComposition()
        guard let compositionVideoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid)
        else {
            DispatchQueue.main.async {
                completion(.failure(NSError(
                    domain: "MiniMaxApiService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to add composition track"])))
            }
            return
        }

        if let audioTrack = asset.tracks(withMediaType: .audio).first,
           let compositionAudioTrack = composition.addMutableTrack(
               withMediaType: .audio,
               preferredTrackID: kCMPersistentTrackID_Invalid)
        {
            try? compositionAudioTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: asset.duration),
                of: audioTrack,
                at: .zero)
        }

        try? compositionVideoTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: asset.duration),
            of: videoTrack,
            at: .zero)

        let videoLayer = CALayer()
        videoLayer.frame = CGRect(origin: .zero, size: size)
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(origin: .zero, size: size)
        overlayLayer.isGeometryFlipped = true

        guard let watermarkImage = UIImage(named: "watermark", in: .main, with: nil) ?? UIImage(named: "watermark.png")
        else {
            DispatchQueue.main.async {
                completion(.failure(NSError(
                    domain: "MiniMaxApiService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Watermark image not found"])))
            }
            return
        }

        let maxWidth = size.width - watermarkHorizontalInset * 2
        let maxHeight = size.height - watermarkVerticalInset * 2
        let imgSize = watermarkImage.size
        let scale = min(maxWidth / imgSize.width, maxHeight / imgSize.height, 1)
        let watermarkWidth = imgSize.width * scale
        let watermarkHeight = imgSize.height * scale
        let x = (size.width - watermarkWidth) / 2
        let y = (size.height - watermarkHeight) / 2

        let watermarkLayer = CALayer()
        watermarkLayer.contents = watermarkImage.cgImage
        watermarkLayer.contentsGravity = .resizeAspect
        watermarkLayer.frame = CGRect(x: x, y: y, width: watermarkWidth, height: watermarkHeight)
        overlayLayer.addSublayer(watermarkLayer)

        let parentLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: size)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)

        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = size
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: parentLayer)

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        let transform = videoTrack.preferredTransform
        layerInstruction.setTransform(transform, at: .zero)
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]

        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality)
        else {
            DispatchQueue.main.async {
                completion(.failure(NSError(
                    domain: "MiniMaxApiService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to create export session"])))
            }
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = videoComposition

        exportSession.exportAsynchronously {
            switch exportSession.status {
                case .completed:
                    do {
                        let data = try Data(contentsOf: outputURL)
                        try? FileManager.default.removeItem(at: inputURL)
                        try? FileManager.default.removeItem(at: outputURL)
                        DispatchQueue.main.async { completion(.success(data)) }
                    } catch {
                        try? FileManager.default.removeItem(at: inputURL)
                        try? FileManager.default.removeItem(at: outputURL)
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                case .failed, .cancelled:
                    try? FileManager.default.removeItem(at: inputURL)
                    try? FileManager.default.removeItem(at: outputURL)
                    DispatchQueue.main.async {
                        completion(.failure(exportSession.error ?? NSError(
                            domain: "MiniMaxApiService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Export failed"])))
                    }
                default:
                    break
            }
        }
    }

    private func real_generateVideoFromText(
        prompt: String,
        quality: Quality,
        duration: Duration,
        completion: @escaping (Result<Data, Error>) -> Void)
    {
        guard let url = URL(string: "\(baseURL)/v1/video_generation") else {
            completion(.failure(NSError(
                domain: "MiniMaxApiService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(apiKey)", forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Apphud.userID(), forHTTPHeaderField: "x-user-id")
        request.setValue(try! generateXToken(), forHTTPHeaderField: "x-token")

        let body: [String: Any] = [
            "model": "MiniMax-Hailuo-2.3",
            "prompt": prompt,
            "prompt_optimizer": true,
            "duration": Int(duration.duration) ?? 6,
            "resolution": quality.resolution,
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            print(error.localizedDescription)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            self.handleGenerationResponse(
                data: data,
                response: response,
                error: error,
                source: .text,
                completion: completion)
        }
        task.resume()
    }

    private func real_generateVideoFromImage(
        image: UIImage,
        prompt: String,
        quality: Quality,
        duration: Duration,
        completion: @escaping (Result<Data, Error>) -> Void)
    {
        guard let url = URL(string: "\(baseURL)/v1/video_generation") else {
            completion(.failure(NSError(
                domain: "MiniMaxApiService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let jpegData = image.jpegData(compressionQuality: 0.9)
        let pngData = image.pngData()
        let imageData: Data
        let mimeType: String
        if let jd = jpegData {
            imageData = jd
            mimeType = "image/jpeg"
        } else if let pd = pngData {
            imageData = pd
            mimeType = "image/png"
        } else {
            completion(.failure(NSError(
                domain: "MiniMaxApiService",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Unable to encode image"])))
            return
        }
        let base64 = imageData.base64EncodedString()
        let dataURL = "data:\(mimeType);base64,\(base64)"

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(apiKey)", forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Apphud.userID(), forHTTPHeaderField: "x-user-id")
        request.setValue(try! generateXToken(), forHTTPHeaderField: "x-token")

        let body: [String: Any] = [
            "model": "MiniMax-Hailuo-2.3",
            "first_frame_image": dataURL,
            "prompt": prompt,
            "prompt_optimizer": true,
            "duration": Int(duration.duration) ?? 6,
            "resolution": quality.resolution,
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            self.handleGenerationResponse(
                data: data,
                response: response,
                error: error,
                source: .image,
                completion: completion)
        }
        task.resume()
    }

    private func handleGenerationResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        source: MockVideoSource,
        completion: @escaping (Result<Data, Error>) -> Void)
    {
        if let error = error {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? -1
        let responseBody = data.flatMap { String(data: $0, encoding: .utf8) } ?? "<no body>"
        print("[MiniMax] handleGenerationResponse | status: \(statusCode) | body: \(responseBody)")

        guard let data = data, let httpResponse, httpResponse.statusCode == 200 else {
            print("[MiniMax] handleGenerationResponse FAILED | status: \(statusCode) | body: \(responseBody)")
            DispatchQueue.main.async {
                completion(.failure(NSError(
                    domain: "MiniMaxApiService",
                    code: statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid response (status: \(statusCode)): \(responseBody)"])))
            }
            return
        }

        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw NSError(
                    domain: "MiniMaxApiService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])
            }

            if let baseResp = json["base_resp"] as? [String: Any],
               let apiStatusCode = baseResp["status_code"] as? Int,
               apiStatusCode == 1008
            {
                let apiMessage = baseResp["status_msg"] as? String ?? "Unknown API error"
                print("[MiniMax] API error | code: \(apiStatusCode) | message: \(apiMessage)")
                DispatchQueue.main.async {
                    completion(.failure(NSError(
                        domain: "MiniMaxApiService",
                        code: apiStatusCode,
                        userInfo: [NSLocalizedDescriptionKey: apiMessage])))
                }
                return
            }

            guard let taskId = json["task_id"] as? String, !taskId.isEmpty else {
                throw NSError(
                    domain: "MiniMaxApiService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Missing or empty task_id"])
            }

            pollTaskStatus(taskId: taskId, attempts: 0, source: source, completion: completion)
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }

    private func pollTaskStatus(
        taskId: String,
        attempts: Int,
        source: MockVideoSource,
        completion: @escaping (Result<Data, Error>) -> Void)
    {
        if attempts > 60 {
            completion(.failure(NSError(
                domain: "MiniMaxApiService",
                code: -4,
                userInfo: [NSLocalizedDescriptionKey: "Timeout polling task status"])))
            return
        }

        guard let url = URL(string: "\(baseURL)/v1/query/video_generation?task_id=\(taskId)") else {
            completion(.failure(NSError(
                domain: "MiniMaxApiService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid query URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("\(apiKey)", forHTTPHeaderField: "x-api-key")
        request.setValue(Apphud.userID(), forHTTPHeaderField: "x-user-id")
        request.setValue(try! generateXToken(), forHTTPHeaderField: "x-token")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200
            else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(
                        domain: "MiniMaxApiService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid query response"])))
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let status = json["status"] as? String
                {
                    if status == "Success" {
                        if let fileId = json["file_id"] as? String {
                            self.downloadVideo(fileId: fileId, source: source, completion: completion)
                        } else {
                            throw NSError(
                                domain: "MiniMaxApiService",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Missing file_id"])
                        }
                    } else if status == "Fail" {
                        throw NSError(
                            domain: "MiniMaxApiService",
                            code: -5,
                            userInfo: [NSLocalizedDescriptionKey: "Task failed"])
                    } else {
                        DispatchQueue.global().asyncAfter(deadline: .now() + 5.0) {
                            self.pollTaskStatus(
                                taskId: taskId,
                                attempts: attempts + 1,
                                source: source,
                                completion: completion)
                        }
                    }
                } else {
                    throw NSError(
                        domain: "MiniMaxApiService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid status JSON"])
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }

    private func downloadVideo(
        fileId: String,
        source: MockVideoSource,
        completion: @escaping (Result<Data, Error>) -> Void)
    {
        guard let url = URL(string: "\(baseURL)/v1/files/retrieve?file_id=\(fileId)") else {
            completion(.failure(NSError(
                domain: "MiniMaxApiService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid retrieve URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("\(apiKey)", forHTTPHeaderField: "x-api-key")
        request.setValue(Apphud.userID(), forHTTPHeaderField: "x-user-id")
        request.setValue(try! generateXToken(), forHTTPHeaderField: "x-token")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200
            else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(
                        domain: "MiniMaxApiService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid retrieve response"])))
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let file = json["file"] as? [String: Any],
                   let downloadUrlStr = file["download_url"] as? String,
                   let downloadUrl = URL(string: downloadUrlStr)
                {
                    let downloadTask = URLSession.shared.dataTask(with: downloadUrl) { videoData, _, videoError in
                        if let videoError = videoError {
                            DispatchQueue.main.async {
                                completion(.failure(videoError))
                            }
                            return
                        }
                        guard let videoData = videoData else {
                            DispatchQueue.main.async {
                                completion(.failure(NSError(
                                    domain: "MiniMaxApiService",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "No video data"])))
                            }
                            return
                        }
                        let mockFileURL = self.mockVideosDirectory.appendingPathComponent(source.fileName)
                        try? videoData.write(to: mockFileURL)
                        #if DEBUG
//                            let docsURL = self.mockVideosDocumentsDirectory.appendingPathComponent(source.fileName)
//                            try? videoData.write(to: docsURL)
//                            print("[MiniMaxApiService] Mock video saved: \(docsURL.path)")
                        #endif
                        DispatchQueue.main.async {
                            completion(.success(videoData))
                        }
                    }
                    downloadTask.resume()
                } else {
                    throw NSError(
                        domain: "MiniMaxApiService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Missing download_url"])
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }

    #if DEBUG
        private func mockVideoData(source: MockVideoSource) -> Data? {
            let fileURL = mockVideosDirectory.appendingPathComponent(source.fileName)
            if let data = try? Data(contentsOf: fileURL), !data.isEmpty { return data }
            let bundleURL = Bundle.main.url(
                forResource: "mock_video_\(source.rawValue)",
                withExtension: "data",
                subdirectory: "MockVideos")
                ?? Bundle.main.url(forResource: "mock_video_\(source.rawValue)", withExtension: "data")
            guard let url = bundleURL, let data = try? Data(contentsOf: url), !data.isEmpty else { return nil }
            return data
        }

        private func mock_generateVideoFromText(
            prompt: String,
            quality: Quality,
            duration: Duration,
            completion: @escaping (Result<Data, Error>) -> Void)
        {
            let delay: TimeInterval = shouldFail ? 7.0 : 10.0
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                if self.shouldFail {
                    let err = NSError(
                        domain: "MiniMaxApiService",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "Mocked network error"])
                    DispatchQueue.main.async { completion(.failure(err)) }
                    return
                }
                let producedData = self.mockVideoData(source: .text) ?? Data()
                DispatchQueue.main.async { completion(.success(producedData)) }
            }
        }

        private func mock_generateVideoFromImage(
            image: UIImage,
            prompt: String,
            quality: Quality,
            duration: Duration,
            completion: @escaping (Result<Data, Error>) -> Void)
        {
            let delay: TimeInterval = shouldFail ? 7.0 : 10.0
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                if self.shouldFail {
                    let err = NSError(
                        domain: "MiniMaxApiService",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "Mocked network error (image)"])
                    DispatchQueue.main.async { completion(.failure(err)) }
                    return
                }
                let producedData = self.mockVideoData(source: .image) ?? Data()
                DispatchQueue.main.async { completion(.success(producedData)) }
            }
        }
    #endif

    func generateXToken() throws -> String {
        enum LocalError: Error {
            case invalidKey
            case keyCreateFailed
            case encryptFailed
        }

        let requestId = UUID().uuidString
        let requestData = Data(requestId.utf8)

        let lines = ks
            .components(separatedBy: .newlines)
            .filter { !$0.hasPrefix("-----") && !$0.isEmpty }
        let base64Key = lines.joined()
        guard let keyData = Data(base64Encoded: base64Key) else {
            throw LocalError.invalidKey
        }

        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 2048
        ]

        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData,
                                                attributes as CFDictionary,
                                                &error) else {
            throw error?.takeRetainedValue() ?? LocalError.keyCreateFailed
        }

        guard let encryptedData = SecKeyCreateEncryptedData(
            secKey,
            .rsaEncryptionPKCS1,        // соответствует padding.PKCS1v15 на Python
            requestData as CFData,
            &error
        ) as Data? else {
            throw error?.takeRetainedValue() ?? LocalError.encryptFailed
        }

        return encryptedData.base64EncodedString()
    }
}
