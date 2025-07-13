@testable import ImageFeed
import Foundation

final class ImagesListFetcherMock: ImageFeedFetcher {
    var fetchCalledCount = 0
    private var getsError: Bool
    
    init(getsError: Bool = false) {
        self.getsError = getsError
    }
    
    func fetch<T>(_ requestType: ImageFeed.UnsplashRequestType) async throws -> T where T : Decodable {
        guard !getsError else {
            throw ImageFeed.NetworkError.httpStatusCode(404)
        }
        
        let user = UnsplashUser(identifier: "1", username: "CrazyCoder", firstName: "First Name", lastName: "Last Name", profileImage: UnsplashUser.ProfileImage(small: nil, medium: nil, large: nil), bio: "Some very long bio", location: "Moon", portfolioURL: nil, totalCollections: 1, totalLikes: 10, totalPhotos: 100)
        let somePhoto1 = ImageFeed.PhotoResult(identifier: "TestPhotoId1", height: 400, width: 200, createdAt: nil, description: "description", likedByCurrentUser: false, user: user, urls: PhotoResult.URLKind(full: "full", regular: "regular", small: "small", thumb: "thumb"), links: PhotoResult.LinkKind(own: "", html: "", download: "", downloadLocation: ""), likesCount: 0, downloadsCount: nil, viewsCount: nil)
        
        fetchCalledCount += 1
        print("fetchCalledCount: \(fetchCalledCount)")
        return [somePhoto1] as! T
    }
}
