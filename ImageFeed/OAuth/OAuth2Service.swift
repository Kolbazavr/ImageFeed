import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    var isLoggedIn: Bool { tokenStorage.accessToken != nil }
    private var fetchingTokenTask: Task<String, Error>?
    
    private let fetchyFetcher = FetchyFetcher(clientId: Constants.accessKey)
    private let storage: OAuth2TokenStorage = .shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private init() {}
    
    func fetchOAuthToken(code: String) async throws -> String {
        if let currentTask = fetchingTokenTask {
            return try await currentTask.value
        }
        let newFetchingTokenTask = Task {
                defer { fetchingTokenTask = nil }
                let tokenResponseBody: OAuthTokenResponseBody = try await fetchyFetcher.fetch(.accessToken(code: code))
                let token = tokenResponseBody.accessToken
                saveAccessToken(token)
                return token
        }
        fetchingTokenTask = newFetchingTokenTask
        return try await newFetchingTokenTask.value
    }
    
    func saveAccessToken(_ token: String) {
        storage.accessToken = token
    }
    
    func clearAccessToken() {
        storage.removeToken()
    }
}
