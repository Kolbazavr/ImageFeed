//
//  Errors.swift
//  ImageFeed
//
//  Created by ANTON ZVERKOV on 08.06.2025.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

enum DecodingError: Error {
    case failedToDecode
    var localizedDescription: String { "Failed to decode" }
}

enum URLError: Error {
    case invalidURL
    case missingToken
    var localizedDescription: String {
        return switch self {
        case .invalidURL: "Total failure of URL creation"
        case .missingToken: "The token has left the building"
        }
    }
}

enum ProfileError: Error {
    case invalidUserName
    var localizedDescription: String { "Invalid username" }
}
