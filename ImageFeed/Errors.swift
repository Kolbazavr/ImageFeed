import Foundation

enum NetworkError: Error, LocalizedError {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    var errorDescription: String? {
        return switch self {
        case .httpStatusCode(let code): "HTTP status code: \(code)"
        case .urlRequestError(let error): "URL request error: \(error)"
        case .urlSessionError: "URL session error"
        }
    }
}

enum DecodingError: Error, LocalizedError {
    case failedToDecode
    var errorDescription: String? { "Failed to decode" }
}

enum URLError: Error, LocalizedError {
    case invalidURL
    case missingToken
    var errorDescription: String? {
        return switch self {
        case .invalidURL: "Total failure of URL creation"
        case .missingToken: "The token has left the building"
        }
    }
}

enum ProfileError: Error, LocalizedError {
    case invalidUserName
    var errorDescription: String? { "Invalid username" }
}

enum LikeError: Error, LocalizedError {
    case invalidPhotoID
    var errorDescription: String? { "Error with returned photo ID" }
}
