//
//  UnsplashRequestType.swift
//  ImageFeed
//
//  Created by ANTON ZVERKOV on 05.06.2025.
//

import Foundation

enum UnsplashRequestType {
//    case search(query: String)
    case login
    case accessToken(code: String) //or Bearer Token?
    case userProfile
    case publicProfile(username: String)
    case randomPhotos(count: Int)
    case photoPage(page: Int, perPage: Int)
    //add like photo?
    
    var baseURL: URL? {
        return switch self {
        case .login, .accessToken: Constants.noAPIbaseURL
        default: Constants.apiBaseURL
        }
    }
    
    var path: String {
        return switch self {
        case .login: "/oauth/authorize"
        case .accessToken: "/oauth/token"
        case .userProfile: "/me"
        case .publicProfile(let username): "/users/\(username)"
        case .randomPhotos: "/photos/random"
        case .photoPage: "/photos"
        }
    }
    
    var method: String {
        return switch self {
        case .accessToken: "POST"
        default: "GET"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        return switch self {
        case .login:
            [
                WebKeyConstants.clientID : Constants.accessKey,
                WebKeyConstants.redirectURI : Constants.redirectUri,
                WebKeyConstants.responseType : WebKeyConstants.code,
                WebKeyConstants.scope : Constants.accessScope
            ]
                .compactMap { URLQueryItem(name: $0, value: $1) }
        case .accessToken(let code):
            [
                WebKeyConstants.clientID : Constants.accessKey,
                WebKeyConstants.clientSecret : Constants.secretKey,
                WebKeyConstants.redirectURI : Constants.redirectUri,
                WebKeyConstants.code : code,
                WebKeyConstants.grantType : WebKeyConstants.authorizationCode
            ]
                .compactMap { URLQueryItem(name: $0, value: $1) }
        case .randomPhotos(let count):
            [
                "count": "\(count)"
            ]
                .compactMap { URLQueryItem(name: $0, value: $1) }
        case .photoPage(let page, let perPage):
            [
                "page": "\(page)",
                "per_page": "\(perPage)"
            ]
                .compactMap { URLQueryItem(name: $0, value: $1) }
        default: nil
        }
    }
}
