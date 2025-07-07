import Foundation

enum UnsplashRequestType {
    case login
    case accessToken(code: String)
    case userProfile
    case publicProfile(username: String)
    case randomPhotos(count: Int)
    case photoPage(page: Int, perPage: Int)
    case likeAction(identifier: String, isLiked: Bool)
    
    func baseURL(from config: AuthConfiguration) -> URL? {
        return switch self {
        case .login, .accessToken: config.noAPIbaseURL
        default: config.apiBaseURL
        }
    }
    
    var path: String {
        return switch self {
        case .login: "/oauth/authorize"
        case .accessToken: "/oauth/token"
        case .userProfile: "/me"
        case .publicProfile(let username): "/users/\(username)"
        case .randomPhotos: "/photos/random"
        case .photoPage: "/photos"
        case .likeAction(identifier: let photoID, isLiked: _): "/photos/\(photoID)/like"
        }
    }
    
    var method: String {
        return switch self {
        case .accessToken: "POST"
        case .likeAction(identifier: _, isLiked: let isLiked): isLiked ? "POST" : "DELETE"
        default: "GET"
        }
    }
    
    func queryItems(from config: AuthConfiguration) -> [URLQueryItem]? {
        return switch self {
        case .login:
            [
                WebKeyConstants.clientID : config.accessKey,
                WebKeyConstants.redirectURI : config.redirectURI,
                WebKeyConstants.responseType : WebKeyConstants.code,
                WebKeyConstants.scope : config.accessScope
            ]
                .compactMap { URLQueryItem(name: $0, value: $1) }
        case .accessToken(let code):
            [
                WebKeyConstants.clientID : config.accessKey,
                WebKeyConstants.clientSecret : config.secretKey,
                WebKeyConstants.redirectURI : config.redirectURI,
                WebKeyConstants.code : code,
                WebKeyConstants.grantType : WebKeyConstants.authorizationCode
            ]
                .compactMap { URLQueryItem(name: $0, value: $1) }
        case .randomPhotos(let count):
            [
                "count": "\(count)"
            ]
                .compactMap { URLQueryItem(name: $0, value: $1) }
        case .photoPage(let page, let perPage):
            [
                "page": "\(page)",
                "per_page": "\(perPage)"
            ]
                .compactMap { URLQueryItem(name: $0, value: $1) }
        default: nil
        }
    }
}
