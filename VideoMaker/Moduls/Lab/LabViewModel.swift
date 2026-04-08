import Combine
import CoreData
import Foundation

final class LabViewModel: ObservableObject {
    @Published var items: [LibraryItem] = []

    private var cancellables = Set<AnyCancellable>()
    private let coreDataManager = CoreDataManager.shared

    init() {
        setupBindings()
        loadVideos()
    }

    private func setupBindings() {
        coreDataManager.$generatedVideos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] generatedVideos in
                guard let self = self else { return }
                self.items = generatedVideos.compactMap { video in
                    guard let url = self.coreDataManager.resolvedVideoURL(for: video) else { return nil }
                    return LibraryItem(from: video, resolvedVideoURL: url)
                }
            }
            .store(in: &cancellables)

        coreDataManager.$isLoaded
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.coreDataManager.fetchGeneratedVideos()
            }
            .store(in: &cancellables)
    }

    private func loadVideos() {
        if coreDataManager.isLoaded {
            coreDataManager.fetchGeneratedVideos()
        }
    }

    func deleteVideo(_ item: LibraryItem) {
        if let generatedVideo = item.generatedVideo {
            coreDataManager.deleteGeneratedVideo(generatedVideo)
        }
    }
}
