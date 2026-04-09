internal import CoreData
import Foundation
import UIKit
import Combine

final class CoreDataManager: ObservableObject {
    let container: NSPersistentContainer
    @Published var isLoaded: Bool = false
    
    init() {
        container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            self.container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            
            DispatchQueue.main.async { [weak self] in
                self?.isLoaded = true
            }
        }
    }

//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "CoreDataModel")
//        container.loadPersistentStores { description, error in
//            if let error = error {
//                fatalError("Unable to load persistent stores: \(error)")
//            }
//            DispatchQueue.main.async { [weak self] in
//                self?.isLoaded = true
//                self?.cleanupMissingVideos()
//            }
//        }
//        container.viewContext.automaticallyMergesChangesFromParent = true
//        return container
//    }()

//    var context: NSManagedObjectContext {
//        persistentContainer.viewContext
//    }

//    func saveContext() {
//        guard context.hasChanges else { return }
//        do {
//            try context.save()
//        } catch {
//            print("Error saving context: \(error.localizedDescription)")
//        }
//    }

//    func saveGeneratedVideo(
//        videoURL: URL,
//        prompt: String,
//        duration: String,
//        quality: String,
//        generationMode: String,
//        selectedTemplateId: String? = nil,
//        thumbnailImage: UIImage? = nil,
//        sourceImage: UIImage? = nil) -> LibraryItem
//    {
//        let generatedVideo = GeneratedVideo(context: context)
//        generatedVideo.id = UUID()
//        generatedVideo.videoURL = videoURL
//        generatedVideo.prompt = prompt
//        generatedVideo.duration = duration
//        generatedVideo.quality = quality
//        generatedVideo.generationMode = generationMode
//        generatedVideo.selectedTemplateId = selectedTemplateId
//        generatedVideo.createdAt = Date()
//
//        if let thumbnailImage = thumbnailImage {
//            generatedVideo.thumbnailData = thumbnailImage.jpegData(compressionQuality: 0.8)
//        }
//        if let sourceImage = sourceImage {
//            generatedVideo.sourceImageData = sourceImage.jpegData(compressionQuality: 0.8)
//        }
//
//        saveContext()
//        fetchGeneratedVideos()
//        return LibraryItem(from: generatedVideo)
//    }

//    func fetchGeneratedVideos() {
//        let request: NSFetchRequest<GeneratedVideo> = GeneratedVideo.fetchRequest()
//        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
//
//        do {
//            let fetchedVideos = try context.fetch(request)
//            generatedVideos = fetchedVideos.filter { resolvedVideoURL(for: $0) != nil }
//        } catch {
//            print("Error fetching generated videos: \(error.localizedDescription)")
//        }
//    }

//    func resolvedVideoURL(for video: GeneratedVideo) -> URL? {
//        guard let storedURL = video.videoURL else { return nil }
//        if FileManager.default.fileExists(atPath: storedURL.path) {
//            return storedURL
//        }
//        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//        else {
//            return nil
//        }
//        let fallbackURL = documentsDirectory
//            .appendingPathComponent("GeneratedVideos")
//            .appendingPathComponent(storedURL.lastPathComponent)
//        if FileManager.default.fileExists(atPath: fallbackURL.path) {
//            video.videoURL = fallbackURL
//            saveContext()
//            return fallbackURL
//        }
//        return nil
//    }

//    func deleteGeneratedVideo(_ video: GeneratedVideo) {
//        if let videoURL = video.videoURL {
//            try? FileManager.default.removeItem(at: videoURL)
//        }
//        context.delete(video)
//        saveContext()
//        fetchGeneratedVideos()
//    }

//    func cleanupMissingVideos() {
//        let request: NSFetchRequest<GeneratedVideo> = GeneratedVideo.fetchRequest()
//
//        do {
//            let allVideos = try context.fetch(request)
//            for video in allVideos {
//                if resolvedVideoURL(for: video) == nil {
//                    context.delete(video)
//                }
//            }
//            saveContext()
//            fetchGeneratedVideos()
//        } catch {
//            print("Error cleaning up missing videos: \(error.localizedDescription)")
//        }
//    }

//    func generateThumbnail(from videoURL: URL, completion: @escaping (UIImage?) -> Void) {
//        guard FileManager.default.fileExists(atPath: videoURL.path) else {
//            print("Video file does not exist at path: \(videoURL.path)")
//            completion(nil)
//            return
//        }
//
//        let asset = AVURLAsset(url: videoURL)
//        let imageGenerator = AVAssetImageGenerator(asset: asset)
//        imageGenerator.appliesPreferredTrackTransform = true
//        imageGenerator.maximumSize = CGSize(width: 300, height: 300)
//
//        let time = CMTime(seconds: 1.0, preferredTimescale: 600)
//
//        imageGenerator.generateCGImageAsynchronously(for: time) { cgImage, _, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    print("Error generating thumbnail: \(error)")
//                }
//
//                if let cgImage = cgImage {
//                    completion(UIImage(cgImage: cgImage))
//                } else {
//                    completion(nil)
//                }
//            }
//        }
//    }

//    func getVideosDirectoryURL() -> URL? {
//        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//        else {
//            return nil
//        }
//        return documentsDirectory.appendingPathComponent("GeneratedVideos")
//    }
}
