import Foundation

protocol ProfileImageServiceProtocol {
    var didChangeNotification: Notification.Name { get }
    var avatarURL: URL? { get }
    func fetchProfileImageURL(username: String) async throws
}

final class ProfileImageService: ProfileImageServiceProtocol {
    static let shared = ProfileImageService()
    let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private(set) var avatarURL: URL?
    private let fetchyFetcher: ImageFeedFetcher
    
    private init(fetcher: ImageFeedFetcher = FetchyFetcher(accessToken: OAuth2TokenStorage.shared.accessToken)) {
        self.fetchyFetcher = fetcher
    }
    
    func fetchProfileImageURL(username: String) async throws {
        let userPublicProfile: UnsplashUser = try await fetchyFetcher.fetch(.publicProfile(username: username))
        guard let avatarURLString = userPublicProfile.profileImage.medium,
              let mediumSizeUrl = URL(string: avatarURLString)
        else {
            throw URLError.invalidURL
        }
        avatarURL = mediumSizeUrl
        
        NotificationCenter.default.post(
            name: didChangeNotification,
            object: self,
            userInfo: ["URL": mediumSizeUrl]
        )
    }
}
