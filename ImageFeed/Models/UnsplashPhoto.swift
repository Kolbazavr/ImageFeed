import Foundation

import UIKit

public struct UnsplashPhoto: Decodable {
    public enum URLKind: String, Codable {
        case full
        case regular
        case small
    }
    
    public enum LinkKind: String, Codable {
        case own = "self"
        case html
        case download
        case downloadLocation = "download_location"
    }
    
    public let identifier: String
    public let height: Int
    public let width: Int
    public let user: UnsplashUser
    public let urls: [URLKind: URL]
    public let links: [LinkKind: URL]
    public let likesCount: Int
    public let downloadsCount: Int?
    public let viewsCount: Int?
    
    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case height
        case width
        case user
        case urls
        case links
        case likesCount = "likes"
        case downloadsCount = "downloads"
        case viewsCount = "views"
    }
    
}
