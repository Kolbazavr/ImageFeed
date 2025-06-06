import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let keyChainWrapper = KeychainWrapper.standard
    private init() {}

    var accessToken: String? {
        get { keyChainWrapper.string(forKey: Constants.accessTokenKey) }
        set {
            guard let newValue else { return }
            keyChainWrapper.set(newValue, forKey: Constants.accessTokenKey)
        }
    }
    
    func removeToken() {
        keyChainWrapper.removeObject(forKey: Constants.accessTokenKey)
    }
}
