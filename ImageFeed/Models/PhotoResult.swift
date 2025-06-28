import Foundation

import UIKit

public struct PhotoResult: Decodable {
    
    struct URLKind: Codable {
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
    
    struct LinkKind: Codable {
        let own: String
        let html: String
        let download: String
        let downloadLocation: String
        
        enum CodingKeys: String, CodingKey {
            case own = "self"
            case html
            case download
            case downloadLocation = "download_location"
        }
    }
    
    let identifier: String
    let height: Int
    let width: Int
    let createdAt: String?
    let description: String?
    let likedByCurrentUser: Bool
    let user: UnsplashUser
    let urls: URLKind
    let links: LinkKind
    let likesCount: Int
    let downloadsCount: Int?
    let viewsCount: Int?
    
    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case height
        case width
        case createdAt = "created_at"
        case description
        case likedByCurrentUser = "liked_by_user"
        case user
        case urls
        case links
        case likesCount = "likes"
        case downloadsCount = "downloads"
        case viewsCount = "views"
    }
    
    var size: CGSize {
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
}
