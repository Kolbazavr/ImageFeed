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
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
    
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let tokenURLString = "https://unsplash.com/oauth/token"
    
    static let accessTokenKey = "accessToken"
}

//TODO: To use later?:
//extension Constants {
//    enum Secrets {
//        static let accessKey = Secrets.environmentVariable(named: "UNSPLASH_ACCESS_KEY") ?? ""
//        static let secretKey = Secrets.environmentVariable(named: "UNSPLASH_SECRET_KEY") ?? ""
//        
//        private static func environmentVariable(named name: String) -> String? {
//            guard let infoDictionary = Bundle.main.infoDictionary, let value = infoDictionary[name] as? String else {
//                print("!! Missing Environment Variable: '\(name)'")
//                return nil
//            }
//            return value
//        }
//    }
//}
