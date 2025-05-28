import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: Constants.accessTokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: Constants.accessTokenKey) }
    }
}
