import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let fetchyFetcher = FetchyFetcher(clientId: Constants.accessKey)
    private init() {}
    
//    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void) async {
//        do {
//            let tokenResponseBody: OAuthTokenResponseBody = try await fetchyFetcher.fetch(.accessToken(code: code))
//            handler(.success(tokenResponseBody.accessToken))
//        } catch NetworkError.httpStatusCode(let statusCode) {
//            print("Fetching token: Bad status code: \(statusCode)")
//            handler(.failure(NetworkError.httpStatusCode(statusCode)))
//        } catch DecodingError.failedToDecode {
//            print("Fetching token: \(DecodingError.failedToDecode.localizedDescription)")
//            handler(.failure(DecodingError.failedToDecode))
//        } catch {
//            print("Failed to fetch token: \(error)")
//            handler(.failure(error))
//        }
//    }
    
    func fetchOAuthToken(code: String) async throws -> String {
//        do {
            let tokenResponseBody: OAuthTokenResponseBody = try await fetchyFetcher.fetch(.accessToken(code: code))
//        } catch NetworkError.httpStatusCode(let statusCode) {
//            print("Fetching token: Bad status code: \(statusCode)")
//        } catch DecodingError.failedToDecode {
//            print("Fetching token: \(DecodingError.failedToDecode.localizedDescription)")
//        } catch {
//            print("Failed to fetch token: \(error)")
//        }
        return tokenResponseBody.accessToken
    }
    
//    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
//        guard let request = makeOAuthTokenRequest(code: code) else { return }
//        let task = URLSession.shared.data(for: request) { result in
//            switch result {
//            case .success(let tokenResponseBody):
//                do {
//                    let decoder = JSONDecoder()
//                    let token = try decoder.decode(OAuthTokenResponseBody.self, from: tokenResponseBody).accessToken
//                    handler(.success(token))
//                } catch {
//                    print("Failed to decode token from JSON")
//                    handler(.failure(error))
//                }
//            case .failure(let error):
//                handler(.failure(error))
//            }
//        }
//        task.resume()
//    }
    
//    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
//        guard let tokenURL = URL(string: Constants.tokenURLString) else {
//            print("Could not create tokenURL")
//            return nil
//        }
//        var request = URLRequest(url: tokenURL)
//        request.httpMethod = "POST"
//        
//        let params = [
//            "client_id": Constants.accessKey,
//            "client_secret": Constants.secretKey,
//            "redirect_uri": Constants.redirectUri,
//            "code": code,
//            "grant_type": "authorization_code"
//        ]
//        
//        var components = URLComponents()
//        components.queryItems = params.compactMap { URLQueryItem(name: $0.key, value: $0.value) }
//        
//        request.httpBody = components.query?.data(using: .utf8)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        
//        return request
//    }
}
