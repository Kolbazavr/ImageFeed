import Foundation

enum Constants {
    static let accessKey = "lHCB0PWcn162gTmatf6S0NgUzfm5B0M9rk2wLAlTqoQ"
    static let secretKey = "N7rvuvBRH6LLroOzUK7He-vSm225xK6qkfxe0yAd5Zo"
    static let redirectUri = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let noAPIbaseURL = URL(string: "https://unsplash.com")
    static let apiBaseURL = URL(string: "https://api.unsplash.com")

    static let accessTokenKey = "accessToken"
    
    //Duplicate with UnsplashRequestType (not needed):
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

enum WebKeyConstants {
    static let clientID = "client_id"
    static let clientSecret = "client_secret"
    static let redirectURI = "redirect_uri"
    static let responseType = "response_type"
    static let scope = "scope"
    static let grantType = "grant_type"
    static let authorizationCode = "authorization_code"
    static let code = "code"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString //<--Dublicate
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectUri,
            accessScope: Constants.accessScope,
            authURLString: Constants.unsplashAuthorizeURLString, //<--Dublicate
            defaultBaseURL: Constants.noAPIbaseURL!
        )
    }
}
