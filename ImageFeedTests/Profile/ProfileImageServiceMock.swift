@testable import ImageFeed
import Foundation

final class ProfileImageServiceMock: ProfileImageServiceProtocol {
    var avatarURL: URL?
    
    func fetchProfileImageURL(username: String) async throws {
        avatarURL = URL(string: "example.com")
    }
    
    var didChangeNotification: Notification.Name = .init("Test")
}
