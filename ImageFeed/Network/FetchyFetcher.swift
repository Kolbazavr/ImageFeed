import Foundation

final class FetchyFetcher: ImageFeedFetcher {
    private let requestOMatic: RequestOMatic
    private let decoder: JSONDecoder
    private let session: URLSession
    
    init(authConfig: AuthConfiguration = AuthConfiguration.standard, accessToken: String? = nil) {
        self.requestOMatic = .init(authConfig: authConfig, accessToken: accessToken)
        self.decoder = .init()
        self.session = .shared
    }
    
    func fetch<T: Decodable>(_ requestType: UnsplashRequestType) async throws -> T {
        let unsplashRequest = requestOMatic.request(for: requestType)
        let (data, response) = try await session.data(for: unsplashRequest)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            print("Weird status code")
            throw NetworkError.httpStatusCode(-1)
        }
        guard 200..<300 ~= statusCode else {
            print("Bad status code: \(statusCode)")
            throw NetworkError.httpStatusCode(statusCode)
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding failed")
            throw DecodingError.failedToDecode
        }
    }
}
