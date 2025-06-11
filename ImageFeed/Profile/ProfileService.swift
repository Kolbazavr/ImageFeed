//
//  ProfileService.swift
//  ImageFeed
//
//  Created by ANTON ZVERKOV on 06.06.2025.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    
    private(set) var profile: UnsplashUser?
    
    private var fetchingProfileTask: Task<(), Error>?
    
    private init() {}
    
    func fetchProfile(token: String) async throws {
        guard fetchingProfileTask == nil else {
            print("Someone is already fetching profile")
            try await fetchingProfileTask?.value
            return
        }
        let newFetchingProfileTask = Task {
            defer { self.fetchingProfileTask = nil }
            let fetchyFetcher = FetchyFetcher(accessToken: token)
            profile = try await fetchyFetcher.fetch(.userProfile)
        }
        fetchingProfileTask = newFetchingProfileTask
        try await newFetchingProfileTask.value
    }
}
