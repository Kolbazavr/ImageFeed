import Foundation

protocol ImageFeedFetcher {
    func fetch<T: Decodable>(_ requestType: UnsplashRequestType) async throws -> T
}
