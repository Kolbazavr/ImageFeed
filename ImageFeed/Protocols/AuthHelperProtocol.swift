//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by ANTON ZVERKOV on 07.07.2025.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}
