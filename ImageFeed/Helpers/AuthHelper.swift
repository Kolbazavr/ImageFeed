import Foundation

final class AuthHelper: AuthHelperProtocol {
    private let requestOMatic: RequestOMatic
    
    init(configuration: AuthConfiguration = .standard) {
        self.requestOMatic = RequestOMatic(authConfig: configuration, accessToken: nil)
    }
    
    func authRequest() -> URLRequest? {
        requestOMatic.request(for: .login)
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
