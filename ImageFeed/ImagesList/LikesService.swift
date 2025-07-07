import Foundation

actor LikesService {
    private var pendingLikeRequests: [String : Task<LikeResponse, Error>] = [:]
    private let fetchyFetcher: ImageFeedFetcher
    
    init(fetcher: ImageFeedFetcher = FetchyFetcher(accessToken: OAuth2TokenStorage.shared.accessToken)) {
        self.fetchyFetcher = fetcher
    }
    
    func changeLike(for photoId: String, to isLiked: Bool) async throws -> LikeResponse {
        if let existingTask = pendingLikeRequests[photoId] {
            existingTask.cancel()
            pendingLikeRequests[photoId] = nil
        }
        
        let newLikeTask = Task {
            let likeResponse: LikeResponse = try await fetchyFetcher.fetch(.likeAction(identifier: photoId, isLiked: isLiked))
            pendingLikeRequests[photoId] = nil
            return likeResponse
        }
        
        pendingLikeRequests[photoId] = newLikeTask
        return try await newLikeTask.value
    }
}
