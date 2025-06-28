//
//  LikeResponse.swift
//  ImageFeed
//
//  Created by ANTON ZVERKOV on 22.06.2025.
//

import Foundation

struct LikeResponse: Decodable {
    let photo: PhotoResult
    let user: UnsplashUser
}
