//
//  FetchyFetcher.swift
//  ImageFeed
//
//  Created by ANTON ZVERKOV on 05.06.2025.
//

import Foundation

enum DecodingError: Error {
    case failedToDecode
    var localizedDescription: String { "Failed to decode" }
}

final class FetchyFetcher {
    private let requestOMatic: RequestOMatic
    private let decoder: JSONDecoder
    private let session: URLSession
    
    init(clientId: String, accessToken: String? = nil) {
        self.requestOMatic = .init(clientID: clientId, accessToken: accessToken)
        self.decoder = .init()
        self.session = .shared
    }
    
    func fetch<T: Decodable>(_ requestType: UnsplashRequestType) async throws -> T {
        let unsplashRequest = requestOMatic.request(for: requestType)
        let (data, response) = try await session.data(for: unsplashRequest)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            throw NetworkError.httpStatusCode(-1)
        }
        guard 200..<300 ~= statusCode else {
            throw NetworkError.httpStatusCode(statusCode)
        }
        guard let decodedT = try? decoder.decode(T.self, from: data) else {
            throw DecodingError.failedToDecode
        }
        return decodedT
    }
}
