import Foundation

public struct UnsplashUser: Codable {
    public enum ProfileImageSize: String, Codable {
        case small
        case medium
        case large
    }
    
    public enum LinkKind: String, Codable {
        case html
        case photos
        case likes
        case portfolio
    }
    
    public let identifier: String
    public let username: String
    public let firstName: String?
    public let lastName: String?
    public let name: String?
    public let profileImage: [ProfileImageSize: URL]
    public let bio: String?
    public let links: [LinkKind: URL]
    public let location: String?
    public let portfolioURL: URL?
    public let totalCollections: Int
    public let totalLikes: Int
    public let totalPhotos: Int
    
    private enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case name
            case profileImage = "profile_image"
            case bio
            case links
            case location
            case portfolioURL = "portfolio_url"
            case totalCollections = "total_collections"
            case totalLikes = "total_likes"
            case totalPhotos = "total_photos"
        }
    
    var nameToDisplay: String {
        return switch (name, firstName, lastName) {
        case (.some(let name), .none, .none): name
        case (.none, .some(let firstName), .some(let lastName)): "\(firstName) \(lastName)"
        case (.none, .some(let firstName), .none): "\(firstName)"
        default: username
        }
    }
    
    var profileURL: URL? {
        return URL(string: "https://unsplash.com/@\(username)")
    }
}
