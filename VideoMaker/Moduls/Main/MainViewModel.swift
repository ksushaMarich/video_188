
import Foundation
import Combine
public import CoreData
import SwiftUI

final class MainViewModel: ObservableObject {
    
    @Published var isLoaded: Bool = false
    @Published var results: [LibraryItem] = []
    @Published var isDeletePartPresented: Bool = false
    @Published var shouldUseSettingsFrom: LibraryItem? = nil
    @Published var showFeedbackAlert = false

    private var deletePartDismissWorkItem: DispatchWorkItem?
    private var latestImagesTask: Task<Void, Never>?
    
    func fetchCD(context: NSManagedObjectContext) {
        let fetchRequestResults: NSFetchRequest<GeneratedVideo> = GeneratedVideo.fetchRequest()
        
        fetchRequestResults.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let generatedResults = try context.fetch(fetchRequestResults)
            results = generatedResults.map{
                guard let url = resolvedVideoURL(for: $0, context: context) else { return LibraryItem(from: $0) }
                return LibraryItem(from: $0, resolvedVideoURL: url)
            }
            isLoaded = true
        } catch {
            print("Error CoreData: \(error)")
        }
    }
    
    func create(
        context: NSManagedObjectContext,
        videoURL: URL,
        prompt: String,
        duration: String,
        quality: String,
        generationMode: String,
        selectedTemplateId: String? = nil,
        thumbnailImage: UIImage? = nil,
        sourceImage: UIImage? = nil
    ) -> LibraryItem? {
        let generatedVideo = GeneratedVideo(context: context)
        generatedVideo.id = UUID()
        generatedVideo.videoURL = videoURL
        generatedVideo.prompt = prompt
        generatedVideo.duration = duration
        generatedVideo.quality = quality
        generatedVideo.generationMode = generationMode
        generatedVideo.selectedTemplateId = selectedTemplateId
        generatedVideo.createdAt = Date()
        generatedVideo.sourceImageData = sourceImage?.jpegData(compressionQuality: 1)
        
        guard context.hasChanges else { return nil}
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
        
        fetchCD(context: context)
        return LibraryItem(from: generatedVideo)
    }
    
    func delete(context: NSManagedObjectContext, item: LibraryItem) {
        let request: NSFetchRequest<GeneratedVideo> = GeneratedVideo.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        request.fetchLimit = 1
        
        do {
            if let object = try context.fetch(request).first {
                context.delete(object)
                
                try context.save()
                
                fetchCD(context: context)
                showDeletePart()
            }
        } catch {
            print("Error deleting: \(error.localizedDescription)")
        }
    }
    
    func resolvedVideoURL(for video: GeneratedVideo, context: NSManagedObjectContext) -> URL? {
        guard let storedURL = video.videoURL else { return nil }
        if FileManager.default.fileExists(atPath: storedURL.path) {
            return storedURL
        }
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return nil
        }
        let fallbackURL = documentsDirectory
            .appendingPathComponent("GeneratedVideos")
            .appendingPathComponent(storedURL.lastPathComponent)
        if FileManager.default.fileExists(atPath: fallbackURL.path) {
            video.videoURL = fallbackURL
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
            return fallbackURL
        }
        return nil
    }
    
    func showDeletePart() {
        isDeletePartPresented = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isDeletePartPresented = false
        }
    }
}


