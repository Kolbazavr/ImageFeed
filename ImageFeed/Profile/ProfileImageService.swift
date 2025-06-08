//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by ANTON ZVERKOV on 07.06.2025.
//

import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private(set) var avatarURL: URL?
    private let fetchyFetcher = FetchyFetcher()
    
    private init() {}
    
    func fetchProfileImageURL(username: String) async throws {
        let userPublicProfile: UnsplashUser = try await fetchyFetcher.fetch(.publicProfile(username: username))
        guard let avatarURLString = userPublicProfile.profileImage.medium,
              let mediumSizeUrl = URL(string: avatarURLString)
        else {
            throw URLError.invalidURL
        }
        avatarURL = mediumSizeUrl
        
        NotificationCenter.default.post(
            name: ProfileImageService.didChangeNotification,
            object: self,
            userInfo: ["URL": mediumSizeUrl]
        )
    }
}
