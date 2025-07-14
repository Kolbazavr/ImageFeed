@testable import ImageFeed
import Foundation

final class ProfileServiceMock: ProfileServiceProtocol {
    var profile: ImageFeed.UnsplashUser?
    
    func fetchProfile(token: String) async throws {
        let crazyUser = UnsplashUser(identifier: "1", username: "CrazyCoder", firstName: "First Name", lastName: "Last Name", profileImage: UnsplashUser.ProfileImage(small: nil, medium: nil, large: nil), bio: "Some very long bio", location: "Moon", portfolioURL: nil, totalCollections: 1, totalLikes: 10, totalPhotos: 100)
        profile = crazyUser
    }
}
