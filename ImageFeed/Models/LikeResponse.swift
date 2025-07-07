import Foundation

struct LikeResponse: Decodable {
    let photo: PhotoResult
    let user: UnsplashUser
}
