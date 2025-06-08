import Foundation

struct UnsplashUser: Codable {
    
    struct ProfileImage: Codable {
        let small: String?
        let medium: String?
        let large: String?
    }
    
    let identifier: String
    let username: String
    let firstName: String?
    let lastName: String?
    let name: String?
    let profileImage: ProfileImage
    let bio: String?
    let location: String?
    let portfolioURL: URL?
    let totalCollections: Int
    let totalLikes: Int
    let totalPhotos: Int
    
    private enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case name
            case profileImage = "profile_image"
            case bio
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
