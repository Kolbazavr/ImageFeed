import Foundation

final class ImagesListService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private var photoIdentifiers: Set<String> = []
    private var lastLoadedPage: Int?
    private var loadingTask: Task<Void, Error>?
    private let fetchCount = 10
    
    private let likeService: LikesService = .init()
    private let fetchyFetcher: ImageFeedFetcher
    
    init(fetcher: ImageFeedFetcher = FetchyFetcher(accessToken: OAuth2TokenStorage.shared.accessToken)) {
        self.fetchyFetcher = fetcher
    }
    
    func fetchPhotosNextPage() async throws {
        if let existingLoadingTask = loadingTask {
            try await existingLoadingTask.value
        } else {
            let newLoadingTask = Task {
                defer { self.loadingTask = nil }
                let pageToLoad = (lastLoadedPage ?? 0) + 1
                let loadedPhotos: [PhotoResult] = try await fetchyFetcher.fetch(.photoPage(page: pageToLoad, perPage: fetchCount))
                let filteredPhotos: [PhotoResult] = loadedPhotos.filter { !photoIdentifiers.contains($0.identifier) }
                let convertedPhotos: [Photo] = filteredPhotos.map { .init(photoResult: $0) }
                
                await insertLoadedPhotos(convertedPhotos, forPage: pageToLoad)
            }
            loadingTask = newLoadingTask
            try await newLoadingTask.value
        }
    }
    
    func cancelPendingFetchPhotos() {
        loadingTask?.cancel()
        loadingTask = nil
    }
    
    func changeLikedState(ofPhotoWithId photoId: String, to isLiked: Bool) async throws {
        let likeResponse = try await likeService.changeLike(for: photoId, to: isLiked)
        guard likeResponse.photo.identifier == photoId else {
            print(#function, "Liked photo ID does not match the requested one: \(photoId) != \(likeResponse.photo.identifier)")
            throw LikeError.invalidPhotoID
        }
        guard let index = photos.firstIndex(where: { $0.id == photoId }) else {
            print(#function, "Photo with ID \(photoId) not found in the list.")
            throw LikeError.invalidPhotoID
        }
        let newPhoto = Photo(photoResult: likeResponse.photo)
        
        await MainActor.run {
            self.photos[index] = newPhoto
            NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
        }
        
    }
    
    @MainActor
    private func insertLoadedPhotos(_ newPhotos: [Photo], forPage page: Int) {
        photoIdentifiers.formUnion(newPhotos.map { $0.id })
        photos.append(contentsOf: newPhotos)
        lastLoadedPage = page
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
    }
}
