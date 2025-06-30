import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    init(photoResult: PhotoResult) {
        self.id = photoResult.identifier
        self.size = photoResult.size
        self.createdAt = photoResult.createdAt?.toDateFromISO8601()
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.small
        self.largeImageURL = photoResult.urls.full
        self.isLiked = photoResult.likedByCurrentUser
    }
}
