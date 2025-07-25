import Foundation

final class RequestOMatic {
    private let config: AuthConfiguration
    private var accessToken: String?
    
    init(authConfig: AuthConfiguration, accessToken: String? = nil) {
        self.config = authConfig
        self.accessToken = accessToken
    }
    
    func request(for requestType: UnsplashRequestType) -> URLRequest {
        guard let baseURL = requestType.baseURL(from: config) else {
            print(#function, "Failed to create URLRequest")
            fatalError("Something wrong with baseURL")
        }
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            print(#function, "Failed to create components from URL")
            fatalError("Something wrong with baseURL components")
        }
        components.path = requestType.path
        components.queryItems = requestType.queryItems(from: config)
        
        guard let componentsURL = components.url else {
            print(#function, "I dunno what could go wrong here")
            fatalError("Total failure")
        }
        
        var request = URLRequest(url: componentsURL)
        request.httpMethod = requestType.method
        
        switch (accessToken, requestType) {
        case (.some(let token), _): //I have token, and endpoint doesn't matter
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        case (.none, .accessToken): //I don't have token and requesting for token
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        default: //I don't have token and requesting for public thingy where it is not needed
            request.setValue("Client-ID \(config.accessKey)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
