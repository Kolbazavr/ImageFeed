//
//  Constants.swift
//  ImageFeed
//
//  Created by ANTON ZVERKOV on 21.05.2025.
//

import Foundation

enum Constants {
    static let accessKey = "lHCB0PWcn162gTmatf6S0NgUzfm5B0M9rk2wLAlTqoQ"
    static let secretKey = "N7rvuvBRH6LLroOzUK7He-vSm225xK6qkfxe0yAd5Zo"
    static let redirectUri = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let noAPIbaseURL = URL(string: "https://unsplash.com")
    static let apiBaseURL = URL(string: "https://api.unsplash.com")

    static let accessTokenKey = "accessToken"
}

public enum WebKeyConstants {
    static let clientID = "client_id"
    static let clientSecret = "client_secret"
    static let redirectURI = "redirect_uri"
    static let responseType = "response_type"
    static let scope = "scope"
    static let grantType = "grant_type"
    static let authorizationCode = "authorization_code"
    static let code = "code"
}
