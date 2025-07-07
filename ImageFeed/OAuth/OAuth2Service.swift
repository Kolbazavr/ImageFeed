import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private var fetchingTokenTask: Task<String, Error>?
    private var lastCode: String?
    
    private let fetchyFetcher: ImageFeedFetcher
    private let storage: OAuth2TokenStorage = .shared
    private init(fetcher: ImageFeedFetcher = FetchyFetcher(accessToken: OAuth2TokenStorage.shared.accessToken)) {
        self.fetchyFetcher = fetcher
    }
    
    @MainActor
    func fetchOAuthToken(code: String) async throws -> String {
        if let currentTask = fetchingTokenTask, lastCode == code {
            print("Duplicate token fetch request with same code. Returning active task value.")
            return try await currentTask.value
        } else {
            fetchingTokenTask?.cancel()
            lastCode = code
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
    }
    
    func saveAccessToken(_ token: String) {
        storage.accessToken = token
    }
    
    func clearAccessToken() {
        storage.removeToken()
    }
}
